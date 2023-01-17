import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import ExperimentalInternetComputer "mo:base/ExperimentalInternetComputer";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import GT "./GovernanceTypes";


/**
  Proxy canister for Governance calls. This canister is the one that actually controls neurons.

  Can only be called by its creator, which should be Axon.
*/
shared actor class Proxy(owner: Principal) = this {
  let Governance = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : GT.Service;
  stable var neurons: ?GT.ListNeuronsResponse = null;

  type Management = actor {
    wallet_receive : () -> async Nat;
  };

  // Accept cycles
  public func wallet_receive() : async Nat {
    let amount = Cycles.available();
    Cycles.accept(amount);
  };

  // get cycles
  public query func cycles() : async Nat {
    Cycles.balance();
  };
  

  // get cycles
  public query func metrics() : async {
    owner: Principal;
  } {
    {
      owner = owner;
    };
  };

  public func recycle_cycles(caller: Principal, floor: Nat): async Nat {
      assert(caller == owner);
      let balance: Nat = Cycles.balance();
      if(balance > floor ){
        Cycles.add(balance - floor);
        let ic : Management = actor(Principal.toText(caller));
        let result = await ic.wallet_receive();
        return result;
      };
      return 0;
  };

  // Call list_neurons() and save the list of neurons that this canister controls
  public shared({ caller }) func list_neurons() : async GT.ListNeuronsResponse {
    assert(caller == owner);

    await Governance.list_neurons({
      neuron_ids = [];
      include_neurons_readable_by_caller = true;
    });
  };

  public shared({ caller }) func manage_neuron(args: GT.ManageNeuron) : async GT.ManageNeuronResponse {
    assert(caller == owner);
    await Governance.manage_neuron(args)
  };



  public shared({ caller }) func call_raw(canister: Principal, functionName: Text, argumentBinary: Blob, cycles: Nat) : async Result.Result<Blob, Text> {
    assert(caller == owner);

    if(cycles > 0){
      ExperimentalCycles.add(cycles);
    };
     
    try{
      #ok(await ExperimentalInternetComputer.call(canister, functionName, argumentBinary));
    } catch(e){
      #err(Error.message(e));
    };
  };
}
