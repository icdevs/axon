import Arr "./Array";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import MigrationTypes "migrations/types";
import Time "mo:base/Time";
import TrieSet "mo:base/TrieSet";

import SB "mo:StableBuffer/StableBuffer";

module {
  let T = MigrationTypes.CurrentAxon;

  public func _countVotes(ballots: [T.Ballot]): T.Votes {
    Array.foldLeft<T.Ballot, T.Votes>(
      ballots, { yes = 0; no = 0; notVoted = 0}, func(sums, {vote; votingPower}) {
        if (vote == ?#Yes) {
          { yes = sums.yes + votingPower; no = sums.no; notVoted = sums.notVoted }
        } else if (vote == ?#No) {
          { yes = sums.yes; no = sums.no + votingPower; notVoted = sums.notVoted }
        } else {
          { yes = sums.yes; no = sums.no; notVoted = sums.notVoted + votingPower }
        }
      }
    );
  };

  // Applies a status like Accepted, Rejected or Expired based on current conditions
  public func _applyNewStatus(proposal: T.AxonProposal): T.AxonProposal {
    let now = Time.now();
    _applyNewStatusWithTime(proposal, now);
  };

  public func _applyNewStatusWithTime(proposal: T.AxonProposal, now: Int): T.AxonProposal {
    switch (currentStatus(proposal.status)) {
      case (#Created(_)) {
        if (now >= proposal.timeStart) {
          // Activate voting and check ballots
          Debug.print("_applyNewStatusWithTime:Proposal " # debug_show(proposal.id) # " new status=" # debug_show(#Active(now)));
          return _applyNewStatusWithTime(
            withNewStatus(proposal, #Active(now)),
            now
          )
        } else {
          return proposal;
        }
      };
      case (#Active(_)) {};
      case (#ExecutionStarted(ts)) {
        // If we fail to receive a response after 4 hours, set status to timed out
        let EXECUTION_TIMEOUT = 4 * 60 * 60 * 1_000_000; // 4 hours
        if (now > ts + EXECUTION_TIMEOUT) {
          return withNewStatus(proposal, #ExecutionTimedOut(now))
        }
      };
      case _ {
        return proposal;
      }
    };

    // If proposal is active: Count votes and update status if needed

    let { yes; no; notVoted } = proposal.totalVotes;
    let totalVotingPower = yes + no + notVoted;

    // First, calculate quorum if required, and the absolute threshold
    let (quorumVotes, absoluteThresholdVotes, currentPercent) = switch (proposal.policy.acceptanceThreshold) {
      case (#Percent({ percent; quorum })) {
        Debug.print("need percent " # debug_show(percent));
        switch (quorum) {
          case (?quorum_) {
            let quorumVotes = percentOf(quorum_, totalVotingPower);
            (quorumVotes, percentOf(percent, totalVotingPower), percentOf(percent, yes+no))
          };
          case _ { (0, percentOf(percent, totalVotingPower), percentOf(percent, yes+no)) };
        }
      };
      case (#Absolute(amount)) { (0, amount, percentOf(yes, yes+no)) };
    };
    Debug.print("totalVotes: " # debug_show(proposal.totalVotes) # " quorumVotes: " # debug_show(quorumVotes) # " absoluteThresholdVotes: " # debug_show(absoluteThresholdVotes) # " current pecent: " # debug_show(currentPercent));
    let maybeNewStatus = if (yes >= absoluteThresholdVotes and (yes + no) >= quorumVotes) {
      // Accept if we have exceeded the absolute threshold
      ?(#Accepted(now));
    } else if(now >= proposal.timeEnd and yes >= currentPercent and (yes + no) >= quorumVotes){
      ?(#Accepted(now));
    }else {
      switch (proposal.policy.acceptanceThreshold) {
        case (#Percent({ percent; quorum })) {
          if (now >= proposal.timeEnd) {
            // Voting has ended, accept if yes percent exceed the required threshold
            let totalVotes = no + yes;
            let thresholdOfVoted = percentOf(percent, totalVotes);
            let yesPercentVoted = percentOf(yes, totalVotes);
            if (totalVotes >= quorumVotes and yesPercentVoted > percent) {
              ?(#Accepted(now));
            } else {
              ?(#Expired(now));
            }
          } else if (percentOf(no, totalVotingPower) > percent) {
            // Reject if we cannot reach the absolute threshold
            ?(#Rejected(now));
          } else {
            // Voting still active
            null
          }
        };
        case _ {
          // We don't need to check for Accept here, since that is always checked immediately after voting
          if (absoluteThresholdVotes > yes + notVoted) {
            // Reject if we cannot reach the absolute threshold
            ?(#Rejected(now));
          } else if (now >= proposal.timeEnd) {
            ?(#Expired(now));
          } else {
            // Voting still active
            null
          }
        }
      }
    };
    switch (maybeNewStatus) {
      case (?status) {
        Debug.print("Proposal " # debug_show(proposal.id) # " new status=" # debug_show(status));
        withNewStatus(proposal, status);
      };
      case _ { proposal }
    };
  };

  // If proposal is accepted and conditions are met, return it with status ExecutionQueued
  public func _applyExecutingStatusConditionally(proposal: T.AxonProposal, conditions: Bool) : T.AxonProposal {
    switch (currentStatus(proposal.status), conditions) {
      case (#Accepted(_), true) {
        withNewStatus(proposal, #ExecutionQueued(Time.now()));
      };
      case _ { proposal }
    };
  };

  public func withNewStatus(proposal: T.AxonProposal, status: T.Status): T.AxonProposal {
    SB.add(proposal.status, status);
    proposal;
  };

  public func isCancellable(s: T.Status): Bool {
    switch (s) {
      case (#Created(_)) { true };
      case (#Active(_)) { true };
      case (#Accepted(_)) { true };
      case _ { false };
    }
  };

  public func currentStatus(s: SB.StableBuffer<T.Status>): T.Status {
    SB.get(s, SB.size(s)-1);
  };

  func percentOf(percent: Nat, n: Nat): Nat {
    Int.abs(Float.toInt(Float.ceil(Float.fromInt(percent * n) / (100_000_000 : Float))))
  };

  public func scaleByFraction(n: Nat, numerator: Nat, denominator: Nat): Nat {
    n * numerator / denominator
  };
}
