import Cycles "mo:base/ExperimentalCycles";
import ExperimentalInternetComputer "mo:base/ExperimentalInternetComputer";
import GT "./GovernanceTypes";


/**
  Proxy canister for Governance calls. This canister is the one that actually controls neurons.

  Can only be called by its creator, which should be Axon.
*/
shared actor class Proxy(owner: Principal) = this {
  let Governance = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : GT.Service;
  stable var neurons: ?GT.ListNeuronsResponse = null;

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

  public shared({ caller }) func call_raw(canister: Principal, functionName: Text, argumentBinary: Blob) : async Blob {
    assert(caller == owner);
    await ExperimentalInternetComputer.call(canister, functionName, argumentBinary);
  };
}
