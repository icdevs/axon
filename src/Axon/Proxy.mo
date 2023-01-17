import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import ExperimentalInternetComputer "mo:base/ExperimentalInternetComputer";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Debug "mo:base/Debug";

import GT "./GovernanceTypes";


/**
  Proxy canister for Governance calls. This canister is the one that actually controls neurons.

  Can only be called by its creator, which should be Axon.
*/
shared actor class Proxy(owner: Principal) = this {
  let Governance = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : GT.Service;
  stable var neurons: ?GT.ListNeuronsResponse = null;

  stable var axon = owner;

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

  system func preupgrade() {
    Debug.print("in pre upgrade");
  };

  system func postupgrade() {
    // Restore ledger hashmap from entries
    Debug.print("in post upgrade");
  };
  

  // get cycles
  public query func metrics() : async {
    axon: Principal;
  } {
    {
      axon = axon;
    };
  };

  public func recycle_cycles(caller: Principal, floor: Nat): async Nat {
      assert(caller == axon);
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
    assert(caller == axon);

    await Governance.list_neurons({
      neuron_ids = [];
      include_neurons_readable_by_caller = true;
    });
  };

  public shared({ caller }) func manage_neuron(args: GT.ManageNeuron) : async GT.ManageNeuronResponse {
    assert(caller == axon);
    await Governance.manage_neuron(args)
  };



  public shared({ caller }) func call_raw(canister: Principal, functionName: Text, argumentBinary: Blob, cycles: Nat) : async Result.Result<Blob, Text> {
    Debug.print(debug_show(axon) # " " # debug_show(caller) # " " # debug_show(owner));
    assert(caller == owner);

    Debug.print("in call_raw");

    if(cycles > 0){
      Debug.print("adding cycles");
      ExperimentalCycles.add(cycles);
    };
     
    try{
      Debug.print("trying call");
      #ok(await ExperimentalInternetComputer.call(canister, functionName, argumentBinary));
    } catch(e){
      Debug.print("in error" # Error.message(e));
      #err(Error.message(e));
    };
  };
}
