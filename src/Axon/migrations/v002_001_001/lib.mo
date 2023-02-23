import MigrationTypes "../types";
import v2_0_1_types = "../v002_000_001/types";
import v2_1_1_types = "types";

import Map_lib "mo:map_7_0_0/Map"; 
import Set_lib "mo:map_7_0_0/Set"; 
import SB_lib "mo:stablebuffer_0_2_0/StableBuffer"; 
import Iter "mo:base/Iter";
import None "mo:base/None";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";


module {

  public let Map = Map_lib;
  public let Set = Set_lib;

  let { ihash; nhash; thash; phash; calcHash } = Map;



  public func upgrade(prev_migration_state: MigrationTypes.State, args: MigrationTypes.Args): MigrationTypes.State {

    Debug.print("in upgrade to v2.1.1");

    let axons = SB_lib.init<v2_1_1_types.AxonFull>();

    let prev_state = switch(prev_migration_state){
      case(#v2_0_1(#data(val))) val;
      case(_) Debug.trap("Unexpected migration state");
    };

    for(thisItem in SB_lib.vals(prev_state.axons)){
      

      let activeProposals = SB_lib.init<v2_1_1_types.AxonProposal>();

      for(thisProposal in SB_lib.vals(thisItem.activeProposals)){
        SB_lib.add<v2_1_1_types.AxonProposal>(activeProposals, {
          thisProposal with
          proposal = switch(thisProposal.proposal){
            case(#AxonCommand(cmd)){
              #AxonCommand((switch(cmd.0){
                case(#SetPolicy(cmd)) #SetPolicy({
                  cmd with 
                  minters = #None});
                case(#AddMembers(cmd)) #AddMembers(cmd);
                case(#RemoveMembers(cmd)) #RemoveMembers(cmd);
                case(#SetVisibility(cmd)) #SetVisibility(cmd);
                case(#Motion(cmd)) #Motion(cmd);
                case(#Mint(cmd)) #Mint(cmd);
                case(#Burn(cmd)) #Burn(cmd);
                case(#Transfer(cmd)) #Transfer(cmd);
                case(#Redenominate(cmd)) #Redenominate(cmd);
                case(#AddMinters(cmd)) #AddMinters(cmd);
                case(#RemoveMinters(cmd)) # RemoveMinters(cmd);
              }, cmd.1));
            };
            case(#CanisterCommand(cmd)) #CanisterCommand(cmd);
            case(#NeuronCommand(cmd)) #NeuronCommand(cmd);
          };
          ballots = Map.fromIter<Principal, v2_1_1_types.Ballot>(Iter.map<v2_0_1_types.Ballot, (Principal, v2_1_1_types.Ballot)>(SB_lib.vals<v2_0_1_types.Ballot>(thisProposal.ballots), func(x){
            (x.principal, {var voted_by = null;
            principal = x.principal;
            votingPower = x.votingPower;
            var vote = x.vote;});
          }), phash);
          status = thisProposal.status;
          policy = thisProposal.policy;
        });
      };

      let allProposals = SB_lib.init<v2_1_1_types.AxonProposal>();

      for(thisProposal in SB_lib.vals(thisItem.allProposals)){
        SB_lib.add<v2_1_1_types.AxonProposal>(allProposals,{
          thisProposal with
          proposal = switch(thisProposal.proposal){
            case(#AxonCommand(cmd)){
              #AxonCommand((switch(cmd.0){
                case(#SetPolicy(cmd)) #SetPolicy({
                  cmd with 
                  minters = #None});
                case(#AddMembers(cmd)) #AddMembers(cmd);
                case(#RemoveMembers(cmd)) #RemoveMembers(cmd);
                case(#SetVisibility(cmd)) #SetVisibility(cmd);
                case(#Motion(cmd)) #Motion(cmd);
                case(#Mint(cmd)) #Mint(cmd);
                case(#Burn(cmd)) #Burn(cmd);
                case(#Transfer(cmd)) #Transfer(cmd);
                case(#Redenominate(cmd)) #Redenominate(cmd);
                case(#AddMinters(cmd)) #AddMinters(cmd);
                case(#RemoveMinters(cmd)) # RemoveMinters(cmd);
              },cmd.1));
            };
            case(#CanisterCommand(cmd)) #CanisterCommand(cmd);
            case(#NeuronCommand(cmd)) #NeuronCommand(cmd);
            
          };
           ballots = Map.fromIter<Principal, v2_1_1_types.Ballot>(Iter.map<v2_0_1_types.Ballot, (Principal, v2_1_1_types.Ballot)>(SB_lib.vals<v2_0_1_types.Ballot>(thisProposal.ballots), func(x){
            (x.principal, {var voted_by = null;
            principal = x.principal;
            votingPower = x.votingPower;
            var vote = x.vote;});
          }), phash);
          status = thisProposal.status;
          policy = thisProposal.policy;
        });
      };

      SB_lib.add<v2_1_1_types.AxonFull>(axons, {
        visibility = thisItem.visibility;
        totalStake = thisItem.totalStake;
        var supply = thisItem.supply;
        proxy = actor(Principal.toText(Principal.fromActor(thisItem.proxy)));
        id = thisItem.id;
        neurons = thisItem.neurons;
        name = thisItem.name;
        ledger = thisItem.ledger;
        activeProposals = activeProposals;
        allProposals = allProposals;
        delegations_by_owner = Map.new<Principal, Principal>();
        delegations_by_delegate = Map.new<Principal, Set.Set<Principal>>();
        var lastProposalId = thisItem.lastProposalId;
        policy = thisItem.policy;
      });
    };

    return #v2_1_1(#data(
      {
        var axons = axons;
        var admins = prev_state.admins;
        var creator = prev_state.creator;
      }));
  };

   public func downgrade(migration_state: MigrationTypes.State, args: MigrationTypes.Args): MigrationTypes.State {
    return #v0_0_0(#data);
  };

  
};