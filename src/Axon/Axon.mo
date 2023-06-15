import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import ExperimentalInternetComputer "mo:base/ExperimentalInternetComputer";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import TrieSet "mo:base/TrieSet";

import SB "mo:StableBuffer/StableBuffer";
import Map "mo:map/Map";
import Set "mo:map/Set";

import Admins "admins";

import Arr "./Array";
import GT "./GovernanceTypes";
import IC "./IcManagementTypes";

import Proxy "./Proxy";
import A "./AxonHelpers";
import T "./migrations/v002_000_000/axon_types";

import MigrationTypes "./migrations/types";
import Migrations "./migrations";

import Axon "./Interface";

shared ({ caller = creator }) actor class AxonService() = this {
  let { ihash; nhash; thash; phash; calcHash } = Map;
  // ---- State

  stable var axonEntries_pre: [T.AxonEntries_pre] = [];
  stable var axonEntries_post: [T.AxonEntries] = [];


  stable var _AdminsUD : ?Admins.UpgradeData = null;
  

  stable var migration_state: MigrationTypes.State = #v0_0_0(#data);

  // Do not forget to change #v0_1_0 when you are adding a new migration
  // If you use one previous state in place of #v0_1_0 it will run downgrade methods instead
  migration_state := Migrations.migrate(migration_state, #v2_1_1(#id), {creator = creator; init_axons = axonEntries_post; init_admins= _AdminsUD});

  let #v2_1_1(#data(state_current)) = migration_state;

  let _Admins = Admins.Admins(state_current, creator);

  stable var admin = creator;

  let CurrentTypes = MigrationTypes.CurrentAxon;




  // ---- Constants

  let ic = actor "aaaaa-aa" : IC.Self;
  let Governance = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : GT.Service;

  // Default voting period for active proposals, 1 day
  let DEFAULT_DURATION_SEC = 7 * 24 * 60 * 60;
  // Minimum voting period for active proposals, 4 hours
  let MINIMUM_DURATION_SEC = 4 * 60 * 60;
  // Maximum voting period for active proposals, 7 days
  let MAXIMUM_DURATION_SEC = 7 * 24 * 60 * 60;
  // Maximum time in the future that proposals can be created before voting, 7 days
  let MAXIMUM_FUTURE_START = 7 * 24 * 60 * 60;




  // ---- Administrator Role
  stable var master : Principal = creator;


  // Returns a boolean indicating if the specified principal is an admin.
    /**
  * Checks if the specified principal is an admin.
  * @param {Principal} p - The principal to check.
  * @returns {async} {Bool} - Returns `true` if the principal is an admin, otherwise `false`.
  */
  public query func is_admin(p : Principal) : async Bool {
    _Admins.isAdmin(state_current, p);
  };

  // Returns a list of all the admins.
   /**
  * Returns a list of all the admins.
  * @returns {async} {Array<Principal>} - An array containing all the admins.
  */
  public query ({ caller }) func get_admins() : async [Principal] {
    assert (_Admins.isAdmin(state_current, caller));
    _Admins.getAdmins(state_current);
  };

  // Adds the specified principal as an admin.
  /**
  * Adds the specified principal as an admin.
  * @param {Principal} p - The principal to add as an admin.
  * @returns {async} {void}
  */
  public shared ({ caller }) func add_admin(p : Principal) : async () {
    assert (caller == master);
    //assert (_Admins.isAdmin(caller));
    _Admins.addAdmin(state_current, p, caller);
  };


  // get cycles
   /**
  * Retrieves the current balance of cycles.
  * @returns {async} {Nat} - The current balance of cycles.
  */
  public query func cycles() : async Nat {
    Cycles.balance();
  };

  //update an axon's controller --needed for deleting
  public shared({caller}) func updateSettings(canisterId : Principal, manager : Principal) : async () {
    assert (caller == master);
    let controllers : ?[Principal] = ?[canisterId, manager];

    await ic.update_settings(({
      canister_id = canisterId;
      settings = {
        controllers = controllers;
        freezing_threshold = null;
        memory_allocation = null;
        compute_allocation = null;
      };
    }));
  };

  // Changes the master.
    /**
  * Updates the controller of an axon.
  * This is needed for deletion purposes.
  * @param {Principal} canisterId - The canister ID of the axon.
  * @param {Principal} manager - The new manager's principal.
  * @returns {async} {void}
  */
  public shared ({ caller }) func update_master(p : Principal) : async () {
    assert (caller == master);
    //assert (_Admins.isAdmin(caller));
    master := p;
  };

  // Removes the specified principal as an admin.
    /**
  * Removes the specified principal as an admin.
  * @param {Principal} p - The principal to remove as an admin.
  * @returns {async} {void}
  */
  public shared ({ caller }) func remove_admin(p : Principal) : async () {
    assert (caller == master);
    //assert (_Admins.isAdmin(caller));
    _Admins.removeAdmin(state_current, p, caller);
  };

    /**
  * Mints a specified amount of tokens for a recipient.
  * @param {Principal} caller - The caller's principal.
  * @param {Nat} axonId - The ID of the axon.
  * @param {Principal} p - The recipient's principal.
  * @param {Nat} a - The amount of tokens to mint.
  * @returns {async} {Result<AxonCommandExecution>} - The result of the axon command execution.
  */
  private func _mint(caller : Principal, axonId: Nat, p: Principal, a: Nat) : async* CurrentTypes.Result<CurrentTypes.AxonCommandExecution> {
    let axon = SB.get(state_current.axons, axonId);
    if (not isMinter(axon, caller)) return #err(#Unauthorized);
      

    let command : CurrentTypes.AxonCommandRequest =  #Mint({amount = a; recipient = ?p});
    let response = await* _applyAxonCommand(axon, command);

    var maybeNewAxon: ?CurrentTypes.AxonFull = null;
    switch (response) {
      case (#ok((newAxon,_))) {
        maybeNewAxon := ?SB.get(state_current.axons, newAxon);
      };
      case _ {}
    };

    switch(response){
      case(#ok(val)){
        #ok(val.1);
      };
      case(#err(err)){
        #err(err);
      };
    }
  };

  //let a minter mint
    /**
 * Mints a specified amount of tokens for a recipient.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Principal} p - The recipient's principal.
 * @param {Nat} a - The amount of tokens to mint.
 * @returns {async} {Result<AxonCommandExecution>} - The result of the axon command execution.
 */
  public shared ({ caller }) func mint(axonId: Nat, p : Principal, a: Nat) : async CurrentTypes.Result<CurrentTypes.AxonCommandExecution> {
    return await* _mint(caller, axonId, p, a);
  };
/**
 * Burns a specified amount of tokens owned by a recipient.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Principal} p - The owner's principal.
 * @param {Nat} a - The amount of tokens to burn.
 * @returns {async} {Result<AxonCommandExecution>} - The result of the axon command execution.
 */
  private func _burn(caller : Principal, axonId: Nat, p : Principal, a: Nat) : async* CurrentTypes.Result<CurrentTypes.AxonCommandExecution>{
    let axon = SB.get(state_current.axons, axonId);
    if (not isMinter(axon, caller)) return #err(#Unauthorized);

    let command : CurrentTypes.AxonCommandRequest =  #Burn({amount = a; owner = p});
    var maybeNewAxon: ?CurrentTypes.AxonFull = null;
    let response = await* _applyAxonCommand(axon, command);
    switch (response) {
      case (#ok((newAxon,_))) {
        maybeNewAxon := ?SB.get(state_current.axons, newAxon);
      };
      case _ {}
    };

    switch(response){
      case(#ok(val)){
        #ok(val.1);
      };
      case(#err(err)){
        #err(err);
      };
    }
  };

  //let a minter burn
    /**
 * Burns a specified amount of tokens owned by a recipient.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Principal} p - The owner's principal.
 * @param {Nat} a - The amount of tokens to burn.
 * @returns {async} {Result<AxonCommandExecution>} - The result of the axon command execution.
 */
  public shared ({ caller }) func burn(axonId: Nat, p : Principal, a: Nat) : async CurrentTypes.Result<CurrentTypes.AxonCommandExecution> {
    return await* _burn(caller, axonId, p, a);
  };

  /**
 * Mints or Burns a specified amount of tokens owned by a recipient.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Principal} p - The owner's principal.
 * @param {Nat} a - The amount of tokens to burn.
 * @returns {async} {Result<AxonCommandExecution>} - The result of the axon command execution.
 */
  private func _mint_burn_batch(caller : Principal, axonId: Nat, request: [MigrationTypes.CurrentAxon.MintBurnBatchProposal]) : async* CurrentTypes.Result<CurrentTypes.AxonCommandExecution>{
    let axon = SB.get(state_current.axons, axonId);
    Debug.print("found caller for auth " # debug_show(caller, axon.policy.minters, request) );
    if (not isMinter(axon, caller)) return #err(#Unauthorized);

    let command : CurrentTypes.AxonCommandRequest =  #Mint_Burn_Batch(request);
    var maybeNewAxon: ?CurrentTypes.AxonFull = null;
    let response = await* _applyAxonCommand(axon, command);
    switch (response) {
      case (#ok((newAxon,_))) {
        maybeNewAxon := ?SB.get(state_current.axons, newAxon);
      };
      case _ {}
    };

    switch(response){
      case(#ok(val)){
        #ok(val.1);
      };
      case(#err(err)){
        #err(err);
      };
    }
  };

  public shared ({ caller }) func mint_burn_batch(axon_id: Nat, request : [MigrationTypes.CurrentAxon.MintBurnBatchProposal]) : async CurrentTypes.Result<CurrentTypes.AxonCommandExecution> {
    let tracker = 0;
    let results = Buffer.Buffer<((Nat,Principal,Nat),CurrentTypes.Result<CurrentTypes.AxonCommandExecution>)>(request.size());


    return await* _mint_burn_batch(caller, axon_id, request);
  };

  //upgrades a proxy to the new actor type
    /**
 * Upgrades a proxy to the new actor type.
 * @returns {async} {Array<Result<Bool, Text>>} - An array of results indicating the success or failure of the upgrade process for each axon.
 */
  public shared ({ caller }) func upgradeProxy() : async [Result.Result<Bool,Text>] {
    assert (caller == master);
    let results = Buffer.Buffer<Result.Result<Bool,Text>>(0);
    Debug.print("trying");
    var tracker = 0;
    for(thisAxon in SB.vals(state_current.axons)){
      let proxy  = thisAxon.proxy;
      try{
        Debug.print("trying upgrade");
        let newProxy = await (system Proxy.Proxy)(#upgrade proxy)(Principal.fromActor(this)); // upgrade!
        let axon : CurrentTypes.AxonFull = {
          thisAxon with
          proxy = newProxy;
          var supply = thisAxon.supply;
          var lastProposalId = thisAxon.lastProposalId;
        };
        //send more cycles
        //Cycles.add(2_000_000_000_000);// the ledger arghive needs 2T cycles
        Debug.print("done" );
        let proxy_interface : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));
    
        let sync_policy = await proxy_interface.sync_policy();
        let sync_ledger = await proxy_interface.seed_balance();

        SB.put<CurrentTypes.AxonFull>(state_current.axons, tracker, axon);
        results.add(#ok(true));
      } catch (e){
        results.add(#err(Error.message(e)));
      };
      tracker += 1;
    };

    return Buffer.toArray(results);
  };

  

  //---- Public queries

  /**
 * Retrieves the number of axons.
 * @returns {async} {Nat} - The count of axons.
 */
 public query func count() : async Nat {
    SB.size(state_current.axons);
  };

  
  /**
 * Retrieves the top axons based on their total stake.
 * @returns {async} {Array<AxonPublic>} - An array of axons sorted by total stake in descending order.
 */public query func topAxons() : async [CurrentTypes.AxonPublic] {
    let filtered = Array.mapFilter<CurrentTypes.AxonFull, CurrentTypes.AxonPublic>(SB.toArray(state_current.axons), func(axon) {
      switch (axon.visibility) {
        case (#Public) {
          ?getAxonPublic(axon)
        };
        case _ { null }
      }
    });
    Array.sort<CurrentTypes.AxonPublic>(filtered, func (a, b) {
      if (b.totalStake > a.totalStake) { #greater } else { #less }
    });
  };

  /**
 * Retrieves the public information of an axon by ID.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {AxonPublic} - The public information of the axon.
 */
 public query func axonById(id: Nat) : async CurrentTypes.AxonPublic {
    let axon = SB.get(state_current.axons, id);
    getAxonPublic(axon)
  };

  /**
 * Retrieves the public information of an axon by wallet address.
 * @param {Principal} id - The wallet address of the axon.
 * @returns {async} {?AxonPublic} - The public information of the axon, or null if not found.
 */
 public query func axonByWallet(id: Principal) : async ?CurrentTypes.AxonPublic {
    for(thisAxon in SB.vals(state_current.axons)){
      if(Principal.fromActor(thisAxon.proxy) == id) return ?getAxonPublic(thisAxon)
    };
    return null;
  };

  /**
 * Retrieves the status of an axon by ID.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {CanisterStatusResult} - The status of the axon.
 */
 public shared func axonStatusById(id: Nat) : async IC.CanisterStatusResult {
    let axon = SB.get(state_current.axons, id);
    await ic.canister_status({ canister_id = Principal.fromActor(axon.proxy) });
  };

  /**
 * Retrieves the neuron IDs associated with an axon.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {Array<Nat64>} - An array of neuron IDs.
 */
 public query func getNeuronIds(id: Nat) : async [Nat64] {
    neuronIdsFromInfos(id)
  };

  /**
 * Retrieves the balance of a given axon for a specific principal or caller.
 * @param {Nat} id - The ID of the axon.
 * @param {?Principal} principal - Optional. The principal for which to retrieve the balance. If null, the caller's balance is retrieved.
 * @returns {async} {Nat} - The balance of the axon for the specified principal or caller.
 */
 public query({ caller }) func balanceOf(id: Nat, principal: ?Principal) : async Nat {
    let {ledger} = SB.get(state_current.axons, id);
    Option.get(Map.get(ledger, phash, Option.get(principal, caller)), 0)
  };

  /**
 * Retrieves the ledger entries of an axon by ID.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {Array<LedgerEntry>} - An array of ledger entries sorted in descending order by balance.
 */
 public query({ caller }) func ledger(id: Nat) : async [CurrentTypes.LedgerEntry] {
    let {ledger} = SB.get(state_current.axons, id);
    // sort descending
    Array.sort<CurrentTypes.LedgerEntry>(Iter.toArray(Map.entries<Principal, Nat>(ledger)), func (a, b) {
      if (b.1 > a.1) { #greater } else { #less }
    });
  };

  //---- Permissioned queries

  // Get axons where caller has balance
    /**
 * Retrieves the axons where the caller has a non-zero balance.
 * @returns {async} {Array<AxonPublic>} - An array of axons where the caller has a balance.
 */
 public query({ caller }) func myAxons() : async [CurrentTypes.AxonPublic] {
    Array.mapFilter<CurrentTypes.AxonFull, CurrentTypes.AxonPublic>(SB.toArray<CurrentTypes.AxonFull>(state_current.axons), func(axon) {
      switch (Map.get(axon.ledger, phash, caller)) {
        case (?balance) {
          if (balance > 0) { ?getAxonPublic(axon) }
          else { null }
        };
        case _ { null }
      }
    })
  };

  // Get all full neurons. If private, only owners can call
  /**
 * Retrieves the neurons associated with an axon.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {NeuronsResult} - The result containing the neurons associated with the axon.
 */
  public query({ caller }) func getNeurons(id: Nat) : async CurrentTypes.NeuronsResult {
    let { visibility; ledger; neurons } = SB.get(state_current.axons, id);
    if (visibility == #Private and not isAuthed(caller, ledger)) {
      return #err(#Unauthorized)
    };

    switch (neurons) {
      case (?data) {
        #ok(data)
      };
      case _ { #err(#NoNeurons) }
    }
  };

  // Get single proposal. If private, only owners can call
    /**
 * Retrieves a single proposal by ID.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Nat} proposalId - The ID of the proposal.
 * @returns {async} {Result<AxonProposalPublic>} - The result containing the public information of the proposal.
 */
  public query({ caller }) func getProposalById(axonId: Nat, proposalId: Nat) : async CurrentTypes.Result<CurrentTypes.AxonProposalPublic> {
    let { visibility; ledger; activeProposals; allProposals } = SB.get(state_current.axons, axonId);
    if (visibility == #Private and not isAuthed(caller, ledger)) {
      return #err(#Unauthorized)
    };

    switch (Array.find<CurrentTypes.AxonProposal>(SB.toArray(activeProposals), func(p) { p.id == proposalId })) {
      case (?found) {
        #ok({found with
          ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(found.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
          status = SB.toArray(found.status);
        }
        );
      };
      case _ {
        let item = Array.find<CurrentTypes.AxonProposal>(SB.toArray(allProposals), func(p) { p.id == proposalId });
        switch(item){
          case(null) #err(#NotFound);
          case(?item) #ok{item with
          ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(item.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
          status = SB.toArray(item.status)};
        };
      }
    };
  };

  // Get all active proposals. If private, only owners can call
    /**
 * Retrieves all active proposals of an axon.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {ProposalResult} - The result containing the public information of the active proposals.
 */
  public query({ caller }) func getActiveProposals(id: Nat) : async CurrentTypes.ProposalResult {
    let { visibility; ledger; activeProposals } = SB.get(state_current.axons, id);
    if (visibility == #Private and not isAuthed(caller, ledger)) {
      return #err(#Unauthorized)
    };

    #ok(Array.map<CurrentTypes.AxonProposal, CurrentTypes.AxonProposalPublic>(SB.toArray<CurrentTypes.AxonProposal>(activeProposals), func(p) : CurrentTypes.AxonProposalPublic{
      {p with
        ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(p.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
        status = SB.toArray(p.status);
      };
    }
    ));
  };

  // Get last 100 proposals, optionally before the specified id. If private, only owners can call
  /**
 * Retrieves the last 100 proposals of an axon, optionally before the specified ID.
 * @param {Nat} id - The ID of the axon.
 * @param {?Nat} before - Optional. The ID of the proposal to retrieve proposals before.
 * @returns {async} {ProposalResult} - The result containing the public information of the proposals.
 */
  public query({ caller }) func getAllProposals(id: Nat, before: ?Nat) : async CurrentTypes.ProposalResult {
    let { visibility; ledger; allProposals } = SB.get(state_current.axons, id);
    if (visibility == #Private and not isAuthed(caller, ledger)) {
      return #err(#Unauthorized)
    };

    let filtered = switch(before) {
      case (?before_) {
        Array.filter<CurrentTypes.AxonProposal>(SB.toArray(allProposals), func(p) {
          p.id < before_
        });
      };
      case null { SB.toArray(allProposals) }
    };
    let size = filtered.size();
    if (size == 0) {
      return #ok([]);
    };

    #ok(Array.tabulate<CurrentTypes.AxonProposalPublic>(Nat.min(100, size), func (i) {
      let items = filtered.get(size - i - 1);

      {items with
       ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(items.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
        status = SB.toArray(items.status);
      };
      
    }));
  };

  // Get all motion proposals
   /**
 * Retrieves all motion proposals of an axon.
 * @param {Nat} id - The ID of the axon.
 * @returns {async} {ProposalResult} - The result containing the public information of the motion proposals.
 */
  public query({ caller }) func getMotionProposals(id: Nat) : async CurrentTypes.ProposalResult {
    let { visibility; ledger; allProposals } = SB.get(state_current.axons, id);
    if (visibility == #Private and not isAuthed(caller, ledger)) {
      return #err(#Unauthorized)
    };

    // Filters to only Motion proposals
    let filtered = Array.mapFilter<CurrentTypes.AxonProposal, CurrentTypes.AxonProposalPublic>(SB.toArray(allProposals), func(p) {
      switch(p.proposal) {
        case (#AxonCommand((command,_))) {
          switch (command) {
            case (#Motion(motion)) {
              return ?{p with
                ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(p.ballots), func(x){
                  {
                    votingPower = x.votingPower;
                    vote = x.vote;
                    principal = x.principal;
                    voted_by = x.voted_by;
                  }
                }));
                status = SB.toArray(p.status);
              };
            };
            case _ {
              return null;
            };
          };
        };
        case _ {
          return null
        };
      };
    });

    let size = filtered.size();
    if (size == 0) {
      return #ok([]);
    };

    #ok(filtered);
  };


  //---- Updates

  // Accept cycles
    /**
 * Accepts cycles to the wallet.
 * @returns {async} {Nat} - The amount of accepted cycles.
 */
  public func wallet_receive() : async Nat {
    let amount = Cycles.available();
    Cycles.accept(amount);
  };

  // Accept cycles
  /**
 * Accepts cycles and recycles them for an axon.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Nat} floor - The floor value.
 * @returns {async} {Nat} - The amount of accepted cycles.
 */
  public  shared(msg) func recycle_cycles(axonId: Nat, floor: Nat) : async Nat {
    assert (msg.caller == master);
    let axon = SB.get(state_current.axons, axonId);
    Cycles.accept(Cycles.available());
  };

  // Transfer tokens
    /**
  * Transfers tokens from one axon to another.
  * @param {Nat} id - The ID of the axon.
  * @param {Principal} dest - The destination principal.
  * @param {Nat} amount - The amount of tokens to transfer.
  * @returns {async} {Result} - The result of the token transfer operation.
  */
  public shared({ caller }) func transfer(id: Nat, dest: Principal, amount: Nat) : async CurrentTypes.Result<()> {
    // Verify if token tranfers are allowed for members in the Axon policy
    assert tokenTransfersAllowed(id);

    let {ledger} = SB.get(state_current.axons, id);
    let balance = Option.get(Map.get(ledger, phash, caller), 0);
    if (amount > balance) {
      #err(#InsufficientBalance)
    } else {
      Map.set(ledger, phash, caller, Nat.sub(balance,amount));
      Map.set(ledger, phash, dest, Option.get(Map.get(ledger,phash, dest), 0) + amount);
      #ok
    }
  };

  // Create a new Axon
    /**
  * Creates a new axon.
  * @param {Initialization} init - The initialization parameters for the axon.
  * @returns {async} {Result<AxonPublic>} - The result containing the public information of the created axon.
  */
  public shared({ caller }) func create(init: CurrentTypes.Initialization) : async CurrentTypes.Result<CurrentTypes.AxonPublic> {
    // Verify that the caller has the Administrator role
    assert (_Admins.isAdmin(state_current, caller));

    // Verify at least one ledger entry
    assert(init.ledgerEntries.size() > 0);

    // TODO: Axon creation costs

    let supply = Array.foldLeft<(Principal,Nat), Nat>(init.ledgerEntries, 0, func(sum, c) { sum + c.1 });
    Cycles.add(4_000_000_000_000);
    
    let axon: CurrentTypes.AxonFull = {
      id = SB.size(state_current.axons);
      proxy = await Proxy.Proxy(Principal.fromActor(this));
      name = init.name;
      visibility = init.visibility;
      policy = init.policy;
      var supply = supply;
      ledger = Map.fromIter<Principal, Nat>(init.ledgerEntries.vals(), phash);
      neurons = null;
      totalStake = 0;
      allProposals = SB.init<CurrentTypes.AxonProposal>();
      activeProposals = SB.init<CurrentTypes.AxonProposal>();
      delegations_by_owner = Map.new<Principal,Principal>();
      delegations_by_delegate = Map.new<Principal, Set.Set<Principal>>();
      var lastProposalId = 0;
    };

    Debug.print("adding to axons");

    SB.add(state_current.axons, axon);


    let proxy_interface : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));
    Debug.print("sync policy");
    let sync_policy = await proxy_interface.sync_policy();
    Debug.print("sync ledger");
    let sync_ledger = await proxy_interface.seed_balance();
    let fresh_axon = SB.get(state_current.axons, axon.id);
    #ok(getAxonPublic(fresh_axon))
  };

  // Submit a new Axon proposal
    /**
 * Submits a new proposal for an axon.
 * @param {NewProposal} request - The new proposal request.
 * @returns {async} {Result<AxonProposalPublic>} - The result containing the public information of the created proposal.
 */
  public shared({ caller }) func propose(request: CurrentTypes.NewProposal) : async CurrentTypes.Result<CurrentTypes.AxonProposalPublic> {
    let axon = SB.get(state_current.axons, request.axonId);
    if (not isAuthed(caller, axon.ledger)) {
      return #err(#Unauthorized);
    };

    // If closed set of proposers, check that caller is eligible
    switch (axon.policy.proposers) {
      case (#Closed(owners)) {
        if (not Arr.contains(owners, caller, Principal.equal)) {
          return #err(#NotProposer);
        }
      };
      case _ {};
    };

    // Check that caller has enough balance to propose
    if (Option.get(Map.get(axon.ledger, phash, caller), 0) < axon.policy.proposeThreshold) {
      return #err(#InsufficientBalanceToPropose);
    };

    switch (request.proposal) {
      case (#NeuronCommand((command,_))) {
        if (neuronIdsFromInfos(axon.id).size() == 0) {
          return #err(#NoNeurons);
        };
      };
      case (#AxonCommand((command,_))) {
        switch (command) {

          // Make sure burning is allowed per policy before allowing tranfers for it.
          case (#Burn(burn)) {
            if (Bool.lognot(axon.policy.allowTokenBurn)) {
              return #err(#NotAllowedByPolicy);
            };
          };

          case _ {}
        };
      };
      case (#CanisterCommand((command,_))) {
        // could place any checks here if needed.
        if(command.note.size() > 30000){
          return #err(#Error({error_message="note too long"; error_type = #canister_error}));
        };
      };
    };

    // Snapshot the ledger at creation
    // Get all voters that are not the treasury
    let treasuryId = Principal.fromActor(axon.proxy);
    
    let eligibleVoters: [(Principal, Nat)] = Iter.toArray(
      Iter.filter<(Principal,Nat)>(Map.entries(axon.ledger), 
        func(p:Principal, idx: Nat): Bool{
          p != treasuryId;
        }
      ));

    let delegateSet = switch(Map.get<Principal,Set.Set<Principal>>(axon.delegations_by_delegate, phash, caller)){
        case(null){Set.new<Principal>()};
        case(?val){val};
      };
    
    let ballots = Map.fromIter<Principal, CurrentTypes.Ballot>(Iter.map<CurrentTypes.LedgerEntry, (Principal, CurrentTypes.Ballot)>(eligibleVoters.vals(), func((p: Principal,n : Nat)) {
      (p, {
        var voted_by = null;
        principal = p;
        votingPower = n;
        // Auto vote for caller and delegates
        var vote = if (p == caller or Set.has<Principal>(delegateSet, phash, p)) { ?(#Yes) } else { null };
      })
    }), phash);

    let now = Time.now();
    let timeStart = clamp(
      Option.get(Option.map(request.timeStart, secsToNanos), now),
      now, now + secsToNanos(MAXIMUM_FUTURE_START)
    );

    // Create the proposal, count ballots, then execute if conditions are met
    let newProposal: CurrentTypes.AxonProposal = A._applyExecutingStatusConditionally(A._applyNewStatus({
      id = axon.lastProposalId;
      timeStart = timeStart;
      timeEnd = timeStart + secsToNanos(clamp(
        Option.get(request.durationSeconds, DEFAULT_DURATION_SEC),
        MINIMUM_DURATION_SEC, MAXIMUM_DURATION_SEC
      ));

      ballots = ballots;

      totalVotes = A._countVotes(ballots);
      creator = caller;
      proposal = request.proposal;
      status = SB.fromArray<CurrentTypes.Status>([#Created(now)]);
      policy = axon.policy;
    }), request.execute == ?true and timeStart <= now);

    SB.add<CurrentTypes.AxonProposal>(axon.activeProposals, newProposal);
    axon.lastProposalId := axon.lastProposalId + 1;

    // Start the execution
    switch (A.currentStatus(newProposal.status)) {
      case (#ExecutionQueued(_)) {
        ignore _doExecute(axon.id, newProposal);
      };
      case _ {}
    };

    #ok({newProposal with
      ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(newProposal.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
      status = SB.toArray(newProposal.status);
    });
  };

  // Vote on an active proposal
   /**
 * Votes on an active proposal.
 * @param {VoteRequest} request - The vote request.
 * @returns {async} {Result} - The result of the vote operation.
 */
  public shared({ caller }) func vote(request: CurrentTypes.VoteRequest) : async CurrentTypes.Result<()> {
    let axon = SB.get(state_current.axons, request.axonId);
    if (not isAuthed(caller, axon.ledger)) {
      return #err(#Unauthorized)
    };

    let now = Time.now();
    var result: CurrentTypes.Result<()> = #err(#NotFound);
    var proposal: ?CurrentTypes.AxonProposal = null;

    //let activeProposals = Buffer.Buffer<CurrentTypes.AxonProposal>(0);

    var tracker = 0;
    var foundTracker = ?0;

    label search for(p in SB.vals(axon.activeProposals)){
      
      if (p.id != request.proposalId) {
        tracker += 1;
        continue search;
      };

      /* Allow voting under these statuses:
        - Created, if time has passed timeStart
        - Active
        - Accepted
      */
      let canVote = switch (A.currentStatus(p.status), now >= p.timeStart) {
        case (#Created(_), true) { true };
        case (#Active(_), _) { true };
        case (#Accepted(_), _) { true };
        case _ { false };
      };

      if (not canVote) {
        result := #err(#CannotVote);
        //activeProposals.add(p);
        tracker += 1;
        break search;
      };

      
      let delegateSet = switch(Map.get<Principal,Set.Set<Principal>>(axon.delegations_by_delegate, phash, caller)){
        case(null){Set.new<Principal>()};
        case(?val){val};
      };

      Map.forEach<Principal, CurrentTypes.Ballot>(p.ballots, func(principal: Principal, b: CurrentTypes.Ballot) {
        if (b.principal == caller) {
          if (Option.isSome(b.vote)) {
            result := #err(#AlreadyVoted);
          } else {
            result := #ok();
            b.vote := ?request.vote;
          }
        } else if(Set.has(delegateSet, phash, b.principal)){
          if (Option.isSome(b.vote)) {} else {
            result := #ok();
            b.voted_by := ?caller;
            b.vote :=?request.vote;
          };
        }; 
      });

      proposal := ?A._applyExecutingStatusConditionally(A._applyNewStatus({
        p with 
        totalVotes = A._countVotes(p.ballots);
      }), true);

      SB.put(axon.activeProposals, tracker, Option.unwrap(proposal));
      foundTracker := ?tracker;
      tracker += 1;
    };

    if (Result.isOk(result)) {
      let updatedProposal = Option.unwrap(proposal);
      // Debug.print("updatedProposal " # debug_show(updatedProposal));

      let active_proposals = switch (A.currentStatus(updatedProposal.status)) {
        // Remove from active list if rejected
        case (#Rejected(_)) {
          SB.add<CurrentTypes.AxonProposal>(axon.allProposals, updatedProposal);
          
          SB.fromArray<CurrentTypes.AxonProposal>(Array.filter<CurrentTypes.AxonProposal>(SB.toArray(axon.activeProposals), func(p) {
            p.id != updatedProposal.id
          }))
        };
        case _ { axon.activeProposals };
      };

      SB.put<CurrentTypes.AxonFull>(state_current.axons, axon.id, {
        axon with
        activeProposals = active_proposals;
        var supply = axon.supply;
        var lastProposalId = axon.lastProposalId;
      });

      // Start the execution
      switch (A.currentStatus(updatedProposal.status)) {
        case (#ExecutionQueued(_)) {
          ignore _doExecute(axon.id, updatedProposal);
        };
        case _ {}
      }
    };
    result
  };

  // Delegate to another principal
  public shared({ caller }) func delegate(axonId: Nat, owner: Principal, target_delegate: ?Principal) : async CurrentTypes.Result<()> {
    let axon = SB.get(state_current.axons, axonId);
    let bMinter = isMinter(axon, caller);
    if ((not isAuthed(caller, axon.ledger)) and (not bMinter)) {
      return #err(#Unauthorized)
    };

    if(owner == caller or bMinter){
      let currentDelegate = Map.get<Principal,Principal>(axon.delegations_by_owner, phash, owner);

      switch(target_delegate, currentDelegate){
        case(null, null){
            //not currently following and no longer wants to follow. Should be unreachable
        };
        case(?target_delegate, ?currentDelegate){
          //wants to follow someone new
          ignore Map.put<Principal, Principal>(axon.delegations_by_owner, phash, owner, target_delegate);
        
          switch(Map.get(axon.delegations_by_delegate, phash, target_delegate)){
            case(null){
              let newSet = Set.fromIter<Principal>([owner].vals(), phash);
              ignore Map.put<Principal, Set.Set<Principal>>(axon.delegations_by_delegate, phash, target_delegate, newSet);
            };
            case(?val){
              ignore Set.put(val, phash, owner);
            };
          };

          switch(Map.get<Principal, Set.Set<Principal>>(axon.delegations_by_delegate, phash, currentDelegate)){
            case(null){
              //nothing to do
            };
            case(?val){
              Set.delete(val, phash, owner);
            };
          };
        };
        case(null, ?currentDelegate){
          //setting the current delegate to null
          Map.delete(axon.delegations_by_owner, phash, owner);

          switch(Map.get(axon.delegations_by_delegate, phash, currentDelegate)){
            case(null){
              //nothing to do
            };
            case(?val){
              Set.delete(val, phash, owner);
            };
          };
        };
        case(?target_delegate, null){
          ignore Map.put(axon.delegations_by_owner, phash, owner, target_delegate);
        
          switch(Map.get(axon.delegations_by_delegate, phash, target_delegate)){
            case(null){
              let newSet = Set.fromIter<Principal>([owner].vals(), phash);
              ignore Map.put(axon.delegations_by_delegate, phash, target_delegate, newSet);
            };
            case(?val){
              ignore Set.put(val, phash, owner);
            };
          };
        };
      };
    };

    return #ok;
  };

  // Cancel an active proposal created by caller
   /**
 * Cancels an active proposal created by the caller.
 * @param {Nat} axonId - The ID of the axon.
 * @param {Nat} proposalId - The ID of the proposal.
 * @returns {async} {Result<AxonProposalPublic>} - The result containing the public information of the canceled proposal.
 */
  public shared({ caller }) func cancel(axonId: Nat, proposalId: Nat) : async CurrentTypes.Result<CurrentTypes.AxonProposalPublic> {
    let axon = SB.get(state_current.axons, axonId);
    if (not isAuthed(caller, axon.ledger)) {
      return #err(#Unauthorized)
    };

    let now = Time.now();
    var maybeProposal: ?CurrentTypes.AxonProposal = null;

    let updatedActiveProposals = Buffer.Buffer<CurrentTypes.AxonProposal>(0);
    
    label search for(proposal in SB.vals(axon.activeProposals)) {
      if (proposal.id == proposalId) {
        switch (A.isCancellable(A.currentStatus(proposal.status)), proposal.creator) {
          case (true, caller) {
            let newProposal = A.withNewStatus(proposal, #Cancelled(now));
            maybeProposal := ?newProposal;
            updatedActiveProposals.add(newProposal);
            continue search;
          };
          // Trap if status is not Active or Created
          case _ { assert(false) };
        };
      };

      updatedActiveProposals.add(proposal);
    };

    // Update proposals arrays
    let proposal = Option.unwrap(maybeProposal);
    SB.add(axon.allProposals, proposal);
    SB.put<CurrentTypes.AxonFull>(state_current.axons, axon.id,{
      axon with 
      activeProposals = SB.fromArray<CurrentTypes.AxonProposal>(Array.filter<CurrentTypes.AxonProposal>(updatedActiveProposals.toArray(), func(p) {
        p.id != proposal.id
      }));
      var supply = axon.supply;
      var lastProposalId = axon.lastProposalId;
    });

    #ok({proposal
      with
      ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(proposal.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
      status = SB.toArray(proposal.status);}
    );
  };

  // Queue proposal for execution
   /**
  * Queues a proposal for execution.
  * @param {Nat} axonId - The ID of the axon.
  * @param {Nat} proposalId - The ID of the proposal.
  * @returns {async} {Result<AxonProposalPublic>} - The result containing the public information of the queued proposal.
  */
  public shared({ caller }) func execute(axonId: Nat, proposalId: Nat) : async CurrentTypes.Result<CurrentTypes.AxonProposalPublic> {
    let axon = SB.get(state_current.axons, axonId);
    if (not isAuthed(caller, axon.ledger)) {
      return #err(#Unauthorized)
    };

    var found: ?CurrentTypes.AxonProposal = null;

    let activeProposals = Array.map<CurrentTypes.AxonProposal, CurrentTypes.AxonProposal>(SB.toArray(axon.activeProposals), func(p) {
      if (p.id != proposalId) {
        return p;
      };

      let updatedProposal = A._applyExecutingStatusConditionally(p, true);
      switch (A.currentStatus(updatedProposal.status)) {
        case (#ExecutionQueued(_)) {};
        // Trap if status is not ExecutionQueued
        case _ { assert(false) }
      };
      found := ?updatedProposal;
      updatedProposal;
    });

    SB.put(state_current.axons, axon.id, {
      axon with
      activeProposals = SB.fromArray<CurrentTypes.AxonProposal>(activeProposals);
      var supply = axon.supply;
      var lastProposalId = axon.lastProposalId;
    });

    let proposal = Option.unwrap(found);

    let result = await _doExecute(axon.id, proposal);

    #ok({result with
      ballots = result.ballots;
      status =  result.status;
    });
  };

  // Call list_neurons() and save the list of neurons that this axon's proxy controls
  /**
  * Calls list_neurons() and saves the list of neurons controlled by the axon's proxy.
  * @param {Nat} id - The ID of the axon.
  * @returns {async} {NeuronsResult} - The result containing the list of neurons and the timestamp.
  */
  public shared({ caller }) func sync(id: Nat) : async CurrentTypes.NeuronsResult {
    let axon = SB.get(state_current.axons, id);
    if (axon.visibility == #Private and not isAuthed(caller, axon.ledger)) {
      return #err(#Unauthorized)
    };

    let response = await axon.proxy.list_neurons();
    let neurons = {
      response = response;
      timestamp = Time.now();
    };

    SB.put(state_current.axons, id, {
      axon with 
      var supply = axon.supply;
      neurons = ?neurons;
      totalStake = Array.foldLeft<GT.Neuron, Nat>(response.full_neurons, 0, func(sum, c) {
        sum + Nat64.toNat(c.cached_neuron_stake_e8s)
      });
      var lastProposalId = axon.lastProposalId;
    });

    // Since this will be called from the client periodically, call cleanup
    ignore cleanup(axon.id);

    #ok(neurons)
  };

  // refreshes balances from the proxy wallet which holds state
   /**
  * Refreshes the balances of the specified accounts in the axon's ledger.
  * @param {Nat} axonId - The ID of the axon.
  * @param {Array<{account: Principal, balance: Nat}>} accounts - The accounts and their updated balances.
  * @returns {async} {Array<Result<Bool>>} - The results of the balance refresh operation.
  */
  public shared({ caller }) func refreshBalances(axonId: Nat, accounts : [(account: Principal, balance: Nat)]) : async [CurrentTypes.Result<Bool>] {
    let axon = SB.get(state_current.axons, axonId);

    Debug.print("in refresh");
    if(Principal.fromActor(axon.proxy) != caller){
      return [#err(#Unauthorized)];
    }; //only the proxy can refresh a balance

    let results = Buffer.Buffer<CurrentTypes.Result<Bool>>(accounts.size());
    var supplyChange : Int = 0;
    for(thisAccount in accounts.vals()){
      //here we trust that the balance provided is true since the proxy is the record of account
      let current_balance : Int = Option.get(Map.get(axon.ledger, phash, thisAccount.0),0);
      supplyChange += (thisAccount.1 - current_balance);
      if(thisAccount.1 == 0){
        Map.delete(axon.ledger, phash, thisAccount.0);
      } else {
        Map.set(axon.ledger, phash, thisAccount.0, thisAccount.1);
      };
      Debug.print("adding result");
      
      results.add(#ok(true));
    };
    if(supplyChange > 0){
      axon.supply += Int.abs(supplyChange);
    } else {
       axon.supply -= Int.abs(supplyChange);
    };
    Debug.print("going to array");
    Buffer.toArray(results);
  };

  // Update proposal statuses and move from active to all if needed. Called by sync
    /**
  * Updates the proposal statuses and moves them from active to all if needed.
  * Called by the sync function.
  * @param {Nat} axonId - The ID of the axon.
  * @returns {async} {Result} - The result of the cleanup operation.
  */
  public shared({ caller }) func cleanup(axonId: Nat) : async CurrentTypes.Result<()> {
    let axon = SB.get(state_current.axons, axonId);
    if (not isAuthed(caller, axon.ledger)) {
      return #err(#Unauthorized)
    };

    let finished = Buffer.Buffer<CurrentTypes.AxonProposal>(0);
    let toExecute = Buffer.Buffer<CurrentTypes.AxonProposal>(0);
    let now = Time.now();
    var hasChanges = false;
    let updatedActiveProposals = Array.map<CurrentTypes.AxonProposal, CurrentTypes.AxonProposal>(SB.toArray(axon.activeProposals), func(proposal) {
      let after = A._applyExecutingStatusConditionally(A._applyNewStatus(proposal), true);
      if (SB.size(after.status) != SB.size(proposal.status)) {
        hasChanges := true
      };
      after
    });
    let filteredActiveProposals = Array.filter<CurrentTypes.AxonProposal>(updatedActiveProposals, func(proposal) {
      let shouldKeep = switch (A.currentStatus(proposal.status)) {
        case (#Expired(_)) { false };
        case (#ExecutionQueued(_)) {
          toExecute.add(proposal);
          true
        };
        case _ { true }
      };
      if (not shouldKeep) {
        finished.add(proposal);
      };
      shouldKeep
    });

    // Move finished proposals from active to all
    if (hasChanges or finished.size() > 0) {
      let finishedArr = Buffer.toArray(finished);
      SB.append(axon.allProposals, SB.fromArray<CurrentTypes.AxonProposal>(finishedArr));

      SB.put(state_current.axons, axon.id, {
        axon with 
        activeProposals = SB.fromArray<CurrentTypes.AxonProposal>(filteredActiveProposals);
        var supply = axon.supply;
        var lastProposalId = axon.lastProposalId;
      });
    };

    // Start execution
    for (proposal in toExecute.vals()) {
      ignore _doExecute(axonId, proposal);
    };

    #ok();
  };

  // ---- Internal functions

  // Execute accepted proposal
  /**
    * Executes an accepted proposal.
    * @param {Nat} axonId - The ID of the axon.
    * @param {AxonProposal} proposal - The proposal to execute.
    * @returns {async} {AxonProposalPublic} - The public information of the executed proposal.
    */
  func _doExecute(axonId: Nat, proposal: CurrentTypes.AxonProposal) : async CurrentTypes.AxonProposalPublic {
    switch (A.currentStatus(proposal.status)) {
      case (#ExecutionQueued(_)) {};
      // Trap if status is not ExecutionQueued
      case _ { assert(false) }
    };

    let axon = SB.get(state_current.axons, axonId);

    // Set proposal status to ExecutionStarted. Proposal state is cached during execution
    let startedProposal = A.withNewStatus(proposal, #ExecutionStarted(Time.now()));
    SB.put(state_current.axons, axon.id, {
      axon with 
      activeProposals = SB.fromArray<CurrentTypes.AxonProposal>(Array.map<CurrentTypes.AxonProposal, CurrentTypes.AxonProposal>(SB.toArray(axon.activeProposals), func(p) {
        if (p.id == proposal.id ) { startedProposal }
        else p
      }));
      var supply = axon.supply;
      var lastProposalId = axon.lastProposalId;
    });

    var maybeNewAxon: ?CurrentTypes.AxonFull = null;
    switch (startedProposal.proposal) {
      case (#NeuronCommand((command,_))) {
        // Forward command to specified neurons, or all
        let neuronIds = neuronIdsFromInfos(axon.id);
        let proposalResponses = Buffer.Buffer<CurrentTypes.NeuronCommandResponse>(neuronIds.size());
        let specifiedNeuronIds = Option.get(command.neuronIds, neuronIds);
        for (id in specifiedNeuronIds.vals()) {
          let neuronResponses = Buffer.Buffer<CurrentTypes.ManageNeuronResponseOrProposal>(1);
          try {
            let response = await axon.proxy.manage_neuron({id = ?{id = id}; command = ?command.command});
            neuronResponses.add(#ManageNeuronResponse(#ok(response)));
          } catch (error) {
            // TODO: Command failed to deliver, retry if possible?
            neuronResponses.add(#ManageNeuronResponse(#err(makeError(error))));
          };

          // Save proposal info if MakeProposal command
          switch (neuronResponses.get(0)) {
            case (#ManageNeuronResponse(#ok({command = ?#MakeProposal({ proposal_id = ?({id}) })}))) {
              let (responseOrError, _) = await _tryGetProposal(id, 0);
              neuronResponses.add(#ProposalInfo(responseOrError));
            };
            case _ {}
          };
          proposalResponses.add((id, Buffer.toArray(neuronResponses)));
        };
        //#NeuronCommand((command, ?Buffer.toArray(proposalResponses)))
      };
      case (#AxonCommand((command,_))) {
        let response = await* _applyAxonCommand(axon, command);
        switch (response) {
          case (#ok((newAxon,_))) {
            maybeNewAxon := ?SB.get(state_current.axons, newAxon);
          };
          case _ {}
        };
        //#AxonCommand((command, ?Result.mapOk<(CurrentTypes.AxonFull, CurrentTypes.AxonCommandExecution), CurrentTypes.AxonCommandExecution, CurrentTypes.Error>(maybeNewAxon, func(t) { t.1 })))
      };
      case (#CanisterCommand((command,_))) {
        Debug.print("calling command");
        try{
          let response = switch(await axon.proxy.call_raw(command.canister, command.functionName, command.argumentBinary, command.cycles)){
            case(#ok(response)){
              Debug.print("calling response" # debug_show(response));
              #CanisterCommand((command, ?#reply(response)))};
            case(#err(err)){
              Debug.print("calling error" # debug_show(err));
              #CanisterCommand((command, ?#error(err)))};
          };
        } catch (e){
          Debug.print("calling try error" # Error.message(e));
          //#CanisterCommand((command, ?#error(Error.message(e))))
        };
        
      }
    };
    // Re-select axon
    let newAxon = Option.get(maybeNewAxon, SB.get(state_current.axons, axonId));

    // Save responses and set status to ExecutionFinished
    SB.add(startedProposal.status, #ExecutionFinished(Time.now()));
    
    SB.add(newAxon.allProposals, startedProposal);
    // Move executed proposal from active to all
    SB.put(state_current.axons, newAxon.id, {
      newAxon with 
      activeProposals = SB.fromArray<CurrentTypes.AxonProposal>(Array.filter<CurrentTypes.AxonProposal>(SB.toArray(newAxon.activeProposals), func(p) { p.id != startedProposal.id }));
      var supply = newAxon.supply;
      var lastProposalId = newAxon.lastProposalId;
    });

    {startedProposal with 
      ballots = Iter.toArray(Iter.map<CurrentTypes.Ballot, CurrentTypes.BallotPublic>(Map.vals<Principal, CurrentTypes.Ballot>(startedProposal.ballots), func(x){
            {
              votingPower = x.votingPower;
              vote = x.vote;
              principal = x.principal;
              voted_by = x.voted_by;
            }
          }));
      status =  SB.toArray(startedProposal.status);
    }
  };


  /**
  * Applies an axon command to the axon's state.
  * @param {AxonFull} axon - The full information of the axon.
  * @param {AxonCommandRequest} request - The axon command request.
  * @returns {async*} {Result<(Nat, AxonCommandExecution)>} - The result containing the ID of the axon and the execution result of the command.
  */
  func _applyAxonCommand(axon: CurrentTypes.AxonFull, request: CurrentTypes.AxonCommandRequest) : async* CurrentTypes.Result<(Nat, CurrentTypes.AxonCommandExecution)> {
    switch(request) {
      case (#SetPolicy(policy)) {
        switch (policy.proposers) {
          case (#Closed(current)) {
            if (current.size() == 0) {
              return #err(#CannotExecute);
            };
          };
          case _ {}
        };
        SB.put(state_current.axons, axon.id, {
          axon with
          var supply = axon.supply;
          policy = policy;
          var lastProposalId = axon.lastProposalId;
        });

        #ok((axon.id, #Ok));

      };
      case (#SetVisibility(visibility)) {
        SB.put(state_current.axons, axon.id, {
          axon with
          visibility = visibility;
          var supply = axon.supply;
          var lastProposalId = axon.lastProposalId;
        });
        
        #ok(axon.id, #Ok);
      };
      case (#Motion(motion)) {
        SB.put(state_current.axons, axon.id, {
          axon with 
          var supply = axon.supply;
          var lastProposalId = axon.lastProposalId;
        });

        #ok(axon.id, #Ok);
      };
      case (#AddMembers(principals)) {
        switch (axon.policy.proposers) {
          case (#Closed(current)) {
            let diff = Array.filter<Principal>(principals, func(p) {
              not Arr.contains<Principal>(current, p, Principal.equal)
            });
            Debug.print(" diff " # debug_show(diff));
            SB.put(state_current.axons, axon.id, {
              axon with 
              policy = {
                // set to current + diff
                axon.policy with 
                proposers = #Closed(Array.append(current, diff));
                
              };
              var supply = axon.supply;
              var lastProposalId = axon.lastProposalId;
            });

            #ok(axon.id, #Ok);

          };
          case _ {
            #err(#InvalidProposal);
          }
        }
      };
      case (#RemoveMembers(principals)) {
        switch (axon.policy.proposers) {
          case (#Closed(current)) {
            let diff = Array.filter<Principal>(current, func(c) {
              not Arr.contains<Principal>(principals, c, Principal.equal)
            });
            if (diff.size() == 0) {
              return #err(#CannotExecute)
            };

            SB.put(state_current.axons, axon.id, {
              axon with
              policy = {
                axon.policy with 
                proposers = #Closed(diff);
              };
              var supply = axon.supply;
              var lastProposalId = axon.lastProposalId;
            });

            #ok(axon.id, #Ok);

          };
          case _ {
            #err(#InvalidProposal);
          }
        }
      };
      case (#AddMinters(principals)) {
        let current =  switch (axon.policy.minters) {
          case (#Minters(current)) current;
          case(#None) [];
        };
        
        let diff = Array.filter<Principal>(principals, func(p) {
          not Arr.contains<Principal>(current, p, Principal.equal)
        });
        Debug.print(" diff " # debug_show(diff));
        SB.put(state_current.axons, axon.id, {
          axon with 
          policy = {
            // set to current + diff
            axon.policy with
            minters = #Minters(Array.append(current, diff));
          };
          var supply = axon.supply;
          var lastProposalId = axon.lastProposalId;
        });

        #ok(axon.id, #Ok);
      };
      case (#RemoveMinters(principals)) {
        switch (axon.policy.minters) {
          case (#Minters(current)) {
            let diff = Array.filter<Principal>(current, func(c) {
              not Arr.contains<Principal>(principals, c, Principal.equal)
            });
            if (diff.size() == 0) {
              return #err(#CannotExecute)
            };

            SB.put(state_current.axons, axon.id, {
              axon with
              policy = {
                axon.policy with 
                minters = #Minters(diff);
              };
              var supply = axon.supply;
              var lastProposalId = axon.lastProposalId;
            });

            #ok(axon.id, #Ok);

          };
          case _ {
            #err(#InvalidProposal);
          }
        }
      };
      case (#Redenominate({from; to})) {

        let proxy : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));


        let remote_call = proxy.redenominate(from, to);
        
        let newSupply = A.scaleByFraction(axon.supply, to, from);

        let fresh_axon = SB.get(state_current.axons, axon.id);
        
        SB.put(state_current.axons, axon.id, {
          fresh_axon with 
          var supply = newSupply;
          policy = {
            fresh_axon.policy with
            proposeThreshold = A.scaleByFraction(fresh_axon.policy.proposeThreshold, to, from);
            acceptanceThreshold = switch (fresh_axon.policy.acceptanceThreshold) {
              case (#Absolute(n)) { #Absolute(A.scaleByFraction(n, to, from)) };
              case (p) { p };
            };
          };
          var lastProposalId = axon.lastProposalId;
        });

        #ok(axon.id, #SupplyChanged({ from = axon.supply; to = newSupply }));
      };
      case (#Mint({amount; recipient})) {
        /*
        let dest = Option.get(recipient, Principal.fromActor(this));
        Map.set<Principal, Nat>(axon.ledger, phash, dest, Option.get(Map.get<Principal,Nat>(axon.ledger, phash, dest), 0) + amount);
        let newSupply = axon.supply + amount;
        #ok({
          id = axon.id;
          proxy = axon.proxy;
          name = axon.name;
          visibility = axon.visibility;
          supply = newSupply;
          ledger = axon.ledger;
          policy = axon.policy;
          neurons = axon.neurons;
          totalStake = axon.totalStake;
          allProposals = axon.allProposals;
          activeProposals = axon.activeProposals;
          var lastProposalId = axon.lastProposalId;
        }, #SupplyChanged({ from = axon.supply; to = newSupply }))
        */

        Debug.print("Applying Mint");
        let proxy : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));

        switch( await proxy.mint({
          to = {
            owner = Option.get(recipient, Principal.fromActor(proxy));
            subaccount = null
          };
          amount = amount;
          memo = null;
          created_at_time = null;
        })){
          case(#Err(err)){
            Debug.print(debug_show(err));
            #err(#Error({error_message=debug_show(err); error_type=#canister_error;}));
          };
          case(#Ok(val)){
            Debug.print(debug_show(val));
            let freshAxon = SB.get(state_current.axons, axon.id);
            let newSupply : Nat = freshAxon.supply + amount;
            #ok(axon.id, #SupplyChanged({ from = axon.supply; to = newSupply }));
          };
        };
      };
      case (#Burn({amount; owner})) {
        //let current_balance = Option.get(Map.get(axon.ledger, phash, owner), 0);
        //var tokens_removed : Nat = 0;
        //if (Bool.logor(amount == 0, amount > current_balance)) {
        //  tokens_removed := Option.get(Map.get(axon.ledger, phash, owner), 0);
        //  Map.delete(axon.ledger, phash, owner);
        //} else {
        //  tokens_removed := amount;
        //  Map.set(axon.ledger, phash, owner, Option.get(Map.get(axon.ledger, phash, owner), 0) - amount);
        //};

        Debug.print("Applying Burn");
        let proxy : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));


        switch( await proxy.burn({
          from = {
            owner = owner;
            subaccount = null
          };
          amount = amount;
          memo = null;
          created_at_time = null;
        })){
          case(#Err(err)){
            Debug.print(debug_show(err));
            #err(#Error({error_message=debug_show(err); error_type=#canister_error;}));
          };
          case(#Ok(val)){
            Debug.print(debug_show(val));
            let freshAxon = SB.get(state_current.axons, axon.id);
            let newSupply : Nat = freshAxon.supply - amount;
            #ok(axon.id, #SupplyChanged({ from = axon.supply; to = newSupply }));
          };
        };
      };
      case (#BurnAll({owner})) {
        let current_balance = Option.get(Map.get(axon.ledger, phash, owner), 0);
        //var tokens_removed : Nat = 0;
        //if (Bool.logor(amount == 0, amount > current_balance)) {
        //  tokens_removed := Option.get(Map.get(axon.ledger, phash, owner), 0);
        //  Map.delete(axon.ledger, phash, owner);
        //} else {
        //  tokens_removed := amount;
        //  Map.set(axon.ledger, phash, owner, Option.get(Map.get(axon.ledger, phash, owner), 0) - amount);
        //};

        Debug.print("Applying Burn");
        let proxy : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));


        switch( await proxy.burn({
          from = {
            owner = owner;
            subaccount = null
          };
          amount = current_balance;
          memo = null;
          created_at_time = null;
        })){
          case(#Err(err)){
            Debug.print(debug_show(err));
            #err(#Error({error_message=debug_show(err); error_type=#canister_error;}));
          };
          case(#Ok(val)){
            Debug.print(debug_show(val));
            let freshAxon = SB.get(state_current.axons, axon.id);
            let newSupply : Nat = freshAxon.supply - current_balance;

            #ok(axon.id, #SupplyChanged({ from = axon.supply; to = newSupply }));
          };
        };
      };
      case (#Mint_Burn_Batch(items)) {
        
        //var tokens_removed : Nat = 0;
        //if (Bool.logor(amount == 0, amount > current_balance)) {
        //  tokens_removed := Option.get(Map.get(axon.ledger, phash, owner), 0);
        //  Map.delete(axon.ledger, phash, owner);
        //} else {
        //  tokens_removed := amount;
        //  Map.set(axon.ledger, phash, owner, Option.get(Map.get(axon.ledger, phash, owner), 0) - amount);
        //};

        Debug.print("Applying Transfer Batch " # debug_show(items));
        let proxy : MigrationTypes.CurrentAxon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));

        let requestBuffer = Buffer.Buffer<MigrationTypes.CurrentAxon.MintBurnBatchCommand>(1);
        
        var finalSupplyChange : Int = 0;

        for(thisItem in items.vals()){
          switch(thisItem){
            case(#Mint(val)){
              finalSupplyChange += val.amount;
              requestBuffer.add(#Mint({
                to = {
                  owner = Option.get(val.owner, Principal.fromActor(proxy));
                  subaccount = null;
                };
                amount = val.amount;
                memo = null;
                created_at_time = null;
              }));
            };
            case(#Burn(val)){
              let current_balance = Option.get(Map.get(axon.ledger, phash, val.owner), 0);
              if(current_balance > 0){
                finalSupplyChange -= switch(val.amount){
                  case(?val){val};
                  case(null){switch(Map.get<Principal,Nat>(axon.ledger, phash, val.owner)){
                    case(null) current_balance;
                    case(?val) val;
                  }};
                };
                requestBuffer.add(#Burn({
                  from = {
                    owner = val.owner;
                    subaccount = null;
                  };
                  amount = val.amount;
                  memo = null;
                  created_at_time = null;
                }));
              };
            };
            case(#Balance(val)){
              let current_balance = Option.get(Map.get(axon.ledger, phash, val.owner), 0);
              if(current_balance != val.amount){
                finalSupplyChange -= if(current_balance > val.amount){
                  requestBuffer.add(#Balance({
                    owner = {
                      owner = val.owner;
                      subaccount = null;
                    };
                    amount = val.amount;
                    memo = null;
                    created_at_time = null;
                  }));
                  current_balance - val.amount;
                } else {
                  requestBuffer.add(#Balance({
                    owner = {
                      owner = val.owner;
                      subaccount = null;
                    };
                    amount = val.amount;
                    memo = null;
                    created_at_time = null;
                  }));
                  val.amount - current_balance;
                };
              };
            };
          };
        };

        let results = await proxy.mint_burn_batch(requestBuffer.toArray());

        

        let freshAxon = SB.get(state_current.axons, axon.id);

        
        var tracker = 0;
        for(thisItem in results.vals()){
          switch(thisItem){
            case(#Err(err)){
              Debug.print(debug_show(err));
              if(tracker == 0){
                return #err(#Error({error_message=debug_show(err); error_type=#canister_error;}));
              } else {
                //do we assume they all worked or all failed. 
              }
            };
            case(#Ok(val)){
              Debug.print(debug_show(val));
            };
          };
          tracker += 1;
        };
        let newSupplyInt : Int = freshAxon.supply  + finalSupplyChange;
        #ok(axon.id, #SupplyChanged({ from = axon.supply; to = Int.abs(Int.max(newSupplyInt, 0 )) }));
        
      };
      case (#Transfer({amount; recipient})) {
        //transfer has been depricated. You should now transfer with the proxy using ICRC1
        let senderBalance = Option.get(Map.get(axon.ledger, phash, Principal.fromActor(this)), 0);
        if (senderBalance < amount) {
          return #err(#CannotExecute);
        };

        let proxy : Axon.Proxy = actor(Principal.toText(Principal.fromActor(axon.proxy)));


        switch( await proxy.transfer({
          from_subaccount = null;
          to = {owner = recipient; subaccount = null};
          amount = amount;
          memo = null;
          created_at_time = null;
        })){
          case(#Err(err)){
            Debug.print(debug_show(err));
            #err(#Error({error_message=debug_show(err); error_type=#canister_error;}));
          };
          case(#Ok(val)){
            Debug.print(debug_show(val));
            let freshAxon = SB.get(state_current.axons, axon.id);


            #ok(axon.id, #Transfer({
                receiver = recipient;
                amount = amount;
                senderBalanceAfter = senderBalance - amount;
              }));
          };
        };
      };
    };
  };

  // Attempt to retrieve NNS proposal, tries up to 10 times
  /**
  * Attempts to retrieve an NNS proposal, tries up to 10 times.
  * @param {Nat64} id - The ID of the proposal.
  * @param {Nat} tries - The number of tries.
  * @returns {async} {(Result<ProposalInfo>, Nat)} - The result containing the proposal information and the number of tries.
  */
  func _tryGetProposal(id: Nat64, tries: Nat): async (CurrentTypes.Result<?GT.ProposalInfo>, Nat) {
    try {
      let proposalInfo = await Governance.get_proposal_info(id);
      (#ok(proposalInfo), tries);
    } catch (error) {
      if (tries >= 10) {
        (#err(#ProposalNotFound), tries)
      } else {
        await _tryGetProposal(id, tries + 1);
      }
    };
  };

  // ---- Helpers

  // Returns true if the policy of an axon allows token transfers by members
  /**
  * Returns true if the policy of an axon allows token transfers by members.
  * @param {Nat} id - The ID of the axon.
  * @returns {Bool} - True if token transfers are allowed, false otherwise.
  */
  func tokenTransfersAllowed(id : Nat) : Bool {
    let axon = SB.get(state_current.axons, id);

    if (axon.policy.restrictTokenTransfer) {
      return false;
    } else {
      return true;
    };
  };

  // Returns true if the principal holds a balance in ledger, OR if it's this canister
   /**
  * Returns true if the principal holds a balance in the ledger or if it's this canister.
  * @param {Principal} principal - The principal to check.
  * @param {Ledger} ledger - The ledger of the axon.
  * @returns {Bool} - True if the principal is authorized, false otherwise.
  */
  func isAuthed(principal: Principal, ledger: CurrentTypes.Ledger) : Bool {
    principal == Principal.fromActor(this) or
    (switch (Map.get(ledger,phash, principal)) {
      case (?balance) { balance > 0 };
      case _ { false };
    })
  };

  func isMinter(axon : CurrentTypes.AxonFull, principal: Principal) : Bool{

    switch(axon.policy.minters){
      case(#None) return false;
      case(#Minters(val)){
        var found : ?Principal = null;
        label search for(thisItem in val.vals()){
          if(thisItem == principal){
            found := ?principal;
            break search;
          };
        };
        if(found == null){return false };
        return true;
      };
    };
  };

  // Return neuron IDs from stored neuron_infos
  /**
  * Returns the neuron IDs from the stored neuron infos.
  * @param {Nat} id - The ID of the axon.
  * @returns {Array<Nat64>} - The array of neuron IDs.
  */
  func neuronIdsFromInfos(id: Nat) : [Nat64] {
    switch (SB.get(state_current.axons, id).neurons) {
      case (?{response={neuron_infos}}) {
        Array.map<(Nat64, GT.NeuronInfo), Nat64>(neuron_infos, func(i) { i.0 })
      };
      case _ { [] }
    }
  };

  // Return Axon with own balance
  /**
  * Returns the public information of the axon with its own balance.
  * @param {AxonFull} axon - The full information of the axon.
  * @returns {AxonPublic} - The public information of the axon.
  */
  func getAxonPublic(axon: CurrentTypes.AxonFull): CurrentTypes.AxonPublic {
    {
      id = axon.id;
      proxy = axon.proxy;
      name = axon.name;
      visibility = axon.visibility;
      supply = axon.supply;
      policy = axon.policy;
      balance = Option.get(Map.get(axon.ledger, phash, Principal.fromActor(this)), 0);
      totalStake = axon.totalStake;
      tokenHolders = Map.size(axon.ledger);
    }
  };
/**
  * Converts seconds to nanoseconds.
  * @param {Int} s - The number of seconds.
  * @returns {Int} - The number of nanoseconds.
  */
  func secsToNanos(s: Int): Int { 1_000_000_000 * s };

/**
  * Clamps a number within a specified range.
  * @param {Int} n - The number to clamp.
  * @param {Int} lower - The lower bound of the range.
  * @param {Int} upper - The upper bound of the range.
  * @returns {Int} - The clamped number.
  */
  func clamp(n: Int, lower: Int, upper: Int): Int { Int.min(Int.max(n, lower), upper) };

  /**
  * Creates an error object from an error.
  * @param {Error} e - The error object.
  * @returns {Error} - The error object.
  */
  func makeError(e: Error): CurrentTypes.Error {
    #Error({
      error_message = Error.message(e);
      error_type = Error.code(e);
    })
  };

  // ---- System functions

  system func preupgrade() {
    
  };

  system func postupgrade() {
    // Restore ledger hashmap from entries

    //_Admins.postupgrade(_AdminsUD);
    _AdminsUD := null;
  };
};