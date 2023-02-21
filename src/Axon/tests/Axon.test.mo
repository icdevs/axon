import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

import SB = "mo:StableBuffer/StableBuffer";

import A "../AxonHelpers";
import MigrationTypes "../migrations/types";

let Types = MigrationTypes.CurrentAxon;

let p1 = Principal.fromText("renrk-eyaaa-aaaaa-aaada-cai");
let p2 = Principal.fromText("rno2w-sqaaa-aaaaa-aaacq-cai");
let p3 = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");

let ballots: [Types.Ballot] = [
  {
    var voted_by = null;
    principal = p1;
    votingPower = 50;
    var vote = ?#Yes
  }, {
    principal = p2;
    votingPower = 50;
    var vote = null;
    var voted_by = null;
  }
];

func makeActiveProposal(policy: Types.Policy, ballots: [Types.Ballot]): Types.AxonProposal {
  let theseballots = Types.Map.fromIter<Principal, Types.Ballot>(Iter.map<Types.Ballot, (Principal, Types.Ballot)>(ballots.vals(), func(x: Types.Ballot){
      (x.principal, x);
    }), Types.Map.phash);
  {
    id = 0;
    totalVotes = A._countVotes(theseballots);
    ballots = theseballots;
    timeStart = 10;
    timeEnd = 100;
    creator = p1;
    proposal = #AxonCommand(#SetVisibility(#Public), null);
    status = SB.fromArray<Types.Status>([#Active(0)]);
    policy = policy;
  }
};

func currentStatus(s: SB.StableBuffer<Types.Status>): Types.Status {
  SB.get(s, SB.size(s)-1);
};

let suite = Suite.suite("AxonProposal", [
  Suite.testLazy("only percent: created",
    func(): Text {
      let theseballots = Types.Map.fromIter<Principal, Types.Ballot>(Iter.map<Types.Ballot, (Principal, Types.Ballot)>(ballots.vals(), func(x: Types.Ballot){
      (x.principal, x);
    }), Types.Map.phash);
      let prop0 = A._applyNewStatusWithTime({
        id = 0;
        totalVotes = A._countVotes(theseballots);
        ballots = theseballots;
        timeStart = 10;
        timeEnd = 100;
        creator = p1;
        proposal = #AxonCommand(#SetVisibility(#Public), null);
        status = SB.fromArray([#Created(0)]);
        policy = {
          proposers = #Open;
          proposeThreshold = 0;
          acceptanceThreshold = #Percent({percent = 55_000_000; quorum = null});
          allowTokenBurn = false;
          restrictTokenTransfer = false;
          minters = #None;
        };
      }, 0);
      let prop1 = A._applyNewStatusWithTime(prop0, 10);
      debug_show(currentStatus(prop1.status))
    },
    M.equals(T.text("#Active(+10)"))
  ),

  Suite.test("only percent: auto accept",
    debug_show(currentStatus(A._applyNewStatusWithTime(makeActiveProposal({
      proposers = #Open;
       minters = #None;
      proposeThreshold = 0;
      acceptanceThreshold = #Percent({percent = 50_000_000; quorum = null});
      allowTokenBurn = false;
          restrictTokenTransfer = false;
    }, ballots), 42).status)),
    M.equals(T.text("#Accepted(+42)"))
  ),

  Suite.testLazy("only percent: end time accept",
    func(): Text {
      let prop0 = A._applyNewStatusWithTime(makeActiveProposal({
        proposers = #Open;
         minters = #None;
        proposeThreshold = 0;
        acceptanceThreshold = #Percent({percent = 50_000_000; quorum = null});
        allowTokenBurn = false;
          restrictTokenTransfer = false;
      }, [
        {
          var voted_by = null;
          principal = p1;
          votingPower = 25;
          var vote = ?#Yes
        }, {
          var voted_by = null;
          principal = p2;
          votingPower = 25;
          var vote = ?#No
        }, {
          var voted_by = null;
          principal = p3;
          votingPower = 50;
          var vote = null
        }
      ]), 42);

      Debug.print("only percent:  end time accept: before: " # debug_show(currentStatus(prop0.status)));
      let prop1 = A._applyNewStatusWithTime(prop0, 100);
      Debug.print("only percent:  end time accept: after: " # debug_show(currentStatus(prop1.status)));
      Debug.print("only percent:  end time accept: after: " # debug_show(prop1.status));
      
      debug_show(currentStatus(prop1.status))
    }, M.equals(T.text("#Accepted(+100)"))
  ),

  Suite.testLazy("only percent: expire",
    func(): Text {
      let prop0 = A._applyNewStatusWithTime(makeActiveProposal({
        proposers = #Open;
         minters = #None;
        proposeThreshold = 0;
        acceptanceThreshold = #Percent({percent = 55_000_000; quorum = null});
        allowTokenBurn = false;
          restrictTokenTransfer = false;
      }, [
        {
          var voted_by = null;
          principal = p1;
          votingPower = 25;
          var vote = ?#Yes
        }, {
          var voted_by = null;
          principal = p2;
          votingPower = 25;
          var vote = ?#No
        }, {
          var voted_by = null;
          principal = p3;
          votingPower = 50;
          var vote = null
        }
      ]), 42);
      Debug.print("only percent: expire: before: " # debug_show(currentStatus(prop0.status)));
      let prop1 = A._applyNewStatusWithTime(prop0, 100);
      Debug.print("only percent: expire: after: " # debug_show(currentStatus(prop1.status)));
      Debug.print("only percent: expire: after: " # debug_show(prop1.status));
      debug_show(currentStatus(prop1.status))
    }, M.equals(T.text("#Expired(+100)"))
  ),

  Suite.test("quorum + percent: auto accept",
    debug_show(currentStatus(A._applyNewStatusWithTime(makeActiveProposal({
      proposers = #Open;
       minters = #None;
      proposeThreshold = 0;
      acceptanceThreshold = #Percent({percent = 50_000_000; quorum = ?50_000_000});
      allowTokenBurn = false;
          restrictTokenTransfer = false;
    }, ballots), 42).status)),
    M.equals(T.text("#Accepted(+42)"))
  ),

  Suite.test("quorum + percent: active",
    debug_show(currentStatus(A._applyNewStatusWithTime(makeActiveProposal({
      proposers = #Open;
       minters = #None;
      proposeThreshold = 0;
      acceptanceThreshold = #Percent({percent = 20_000_000; quorum = ?51_000_000});
      allowTokenBurn = false;
          restrictTokenTransfer = false;
    }, ballots), 42).status)),
    M.equals(T.text("#Active(0)"))
  ),

  Suite.test("quorum + percent: active 2",
    debug_show(currentStatus(A._applyNewStatusWithTime(makeActiveProposal({
      proposers = #Open;
       minters = #None;
      proposeThreshold = 1;
      acceptanceThreshold = #Percent({percent = 66_000_000; quorum = ?52_000_000});
      allowTokenBurn = false;
          restrictTokenTransfer = false;
    }, [
      {
        var voted_by = null;
        principal = p1;
        votingPower = 1;
        var vote = ?#Yes
      }, {
        var voted_by = null;
        principal = p2;
        votingPower = 1;
        var vote = null
      }, {
        var voted_by = null;
        principal = p3;
        votingPower = 1;
        var vote = null
      }
    ]), 42).status)),
    M.equals(T.text("#Active(0)"))
  ),

  Suite.test("quorum + percent: auto accept 2",
    debug_show(currentStatus(A._applyNewStatusWithTime(makeActiveProposal({
      proposers = #Open;
       minters = #None;
      proposeThreshold = 0;
      acceptanceThreshold = #Percent({percent = 50_000_000; quorum = ?51_000_000});
      allowTokenBurn = false;
          restrictTokenTransfer = false;
    }, [
      {
        var voted_by = null;
        principal = p1;
        votingPower = 50;
        var vote = ?#Yes
      }, {
        var voted_by = null;
        principal = p2;
        votingPower = 1;
        var vote = ?#No
      }, {
        var voted_by = null;
        principal = p3;
        votingPower = 49;
        var vote = null
      }
    ]), 42).status)),
    M.equals(T.text("#Accepted(+42)"))
  ),

]);
Suite.run(suite);
