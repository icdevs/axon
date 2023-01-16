import MigrationTypes "../types";
import v2_0_1_types = "types";

import Map_lib "mo:map_7_0_0/Map"; 
import SB_lib "mo:stablebuffer_0_2_0/StableBuffer"; 
import None "mo:base/None";

module {

  public let Map = Map_lib;

  let { ihash; nhash; thash; phash; calcHash } = Map;



  public func upgrade(prev_migration_state: MigrationTypes.State, args: MigrationTypes.Args): MigrationTypes.State {

    let axons = SB_lib.init<v2_0_1_types.AxonFull>();

    for(thisItem in args.init_axons.vals()){
      let aLedger = Map.new<Principal, Nat>();
      for(thisLedger in thisItem.ledgerEntries.vals()){
        Map.set(aLedger, phash, thisLedger.0, thisLedger.1);
      };

      let activeProposals = SB_lib.init<v2_0_1_types.AxonProposal>();

      for(thisProposal in thisItem.activeProposals.vals()){
        SB_lib.add<v2_0_1_types.AxonProposal>(activeProposals, {thisProposal with 
          ballots = SB_lib.fromArray<v2_0_1_types.Ballot>(thisProposal.ballots);
          status = SB_lib.fromArray<v2_0_1_types.Status>(thisProposal.status);
          
        });
      };

      let allProposals = SB_lib.init<v2_0_1_types.AxonProposal>();

      for(thisProposal in thisItem.allProposals.vals()){
        SB_lib.add<v2_0_1_types.AxonProposal>(allProposals,{thisProposal with 
          ballots = SB_lib.fromArray<v2_0_1_types.Ballot>(thisProposal.ballots);
          status = SB_lib.fromArray<v2_0_1_types.Status>(thisProposal.status);
        });
      };


      SB_lib.add<v2_0_1_types.AxonFull>(axons, {
        thisItem with
        ledger = aLedger;
        activeProposals = activeProposals;
        allProposals = allProposals;
        var lastProposalId = thisItem.lastProposalId;
        policy = {
          thisItem.policy with
          minters = #None
        };
      });
    };

    return #v2_0_1(#data(
      {
        var axons = axons;
        var admins = switch(args.init_admins){
          case(null){SB_lib.init<Principal>()};
          case(?val) SB_lib.fromArray<Principal>(val.admins);
        };
        var creator = args.creator;
      }));
  };

   public func downgrade(migration_state: MigrationTypes.State, args: MigrationTypes.Args): MigrationTypes.State {
    return #v0_0_0(#data);
  };

  
};