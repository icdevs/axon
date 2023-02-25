import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import ExperimentalInternetComputer "mo:base/ExperimentalInternetComputer";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Debug "mo:base/Debug";

import GT "./GovernanceTypes";
import Axon "./Interface";

import ICRC1 "mo:icrc1/ICRC1";
import ICRC1Types "mo:icrc1/ICRC1/Types";
import ICRC1Account "mo:icrc1/ICRC1/Account";
import ICRC1Utils "mo:icrc1/ICRC1/Utils";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import A "./AxonHelpers";

import Map "mo:map/Map";

import StableTrieMap "mo:StableTrieMap";
import SB "mo:StableBuffer/StableBuffer";
import httpparser "mo:httpparser/lib";
import json "mo:json/JSON";
import AccountIdentifier "mo:principal/AccountIdentifier";


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

  type BatchCommand = {#Mint: {to : ICRC1.Account;
    amount : Nat;
    memo : ?Blob;
    created_at_time : ?Nat64;};
    #Burn: {from : ICRC1.Account;
    amount : ?Nat;
    memo : ?Blob;
    created_at_time : ?Nat64;};
    #Balance: {owner : ICRC1.Account;
    amount : Nat;
    memo : ?Blob;
    created_at_time : ?Nat64;};
  };

  func accept_all_cycles() : Nat{
    let amount = Cycles.available();
    Cycles.accept(amount);
  };

  // Accept cycles
  public func wallet_receive() : async Nat {
    accept_all_cycles();
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
  

  // get metrics
  public query func metrics() : async {
    axon: Principal;
    archive: Principal;
  } {
    {
      axon = axon;
      archive = Principal.fromActor(token.archive.canister);
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

    let response  = await Governance.list_neurons({
      neuron_ids = [];
      include_neurons_readable_by_caller = true;
    });

    neurons := ?response;

    response;
  };

  public shared({ caller }) func manage_neuron(args: GT.ManageNeuron) : async GT.ManageNeuronResponse {
    assert(caller == axon);
    await Governance.manage_neuron(args)
  };

  public type HeaderField = (Text, Text);

  public type StreamingCallbackToken =  {
        content_encoding: Text;
        index: Nat;
        key: Text;
        //sha256: ?Blob;
    };

  public type StreamingStrategy = {
       #Callback: {
          callback: shared () -> async ();
          token: StreamingCallbackToken;
        };
    };


  public type HttpRequest = {
      body: Blob;
      headers: [HeaderField];
      method: Text;
      url: Text;
  };

  public type HTTPResponse = {
    body               : Blob;
    headers            : [HeaderField];
    status_code        : Nat16;
    streaming_strategy : ?StreamingStrategy;
  };


  // Handles http request
  public query(msg) func http_request(rawReq: HttpRequest): async (HTTPResponse) {
    let req = httpparser.parse(rawReq);
    let {host; port; protocol; path; queryObj; anchor; original = url} = req.url;

    let path_size = req.url.path.array.size();
    let path_array = req.url.path.array;


      if(path_size == 0) {
        let main_text = Buffer.Buffer<Text>(1);
        main_text.add("Axon " # Nat.toText(axonId));

        return {
          body = Text.encodeUtf8(Text.join("", main_text.vals()));
          headers = [("Content-Type", "text/plain")];
          status_code = 200;
          streaming_strategy = null;
        };
      } else if(path_size == 1 and path_array[0] == "neurons") {

        let list = switch(neurons){
          case(null){
            [];
          };
          case(?val) val.full_neurons;
        };

        let items = Buffer.Buffer<Text>(1);


        ignore Array.map<GT.Neuron, Text>(list, func (thisItem) : Text {

          let h = HashMap.HashMap<Text, json.JSON>(3, Text.equal, Text.hash);
          
            h.put("id", #String(debug_show(Option.unwrap(thisItem.id))));
            h.put("controller", #String(Principal.toText(Option.unwrap(thisItem.controller))));
            h.put("kyc_verified", #Boolean(thisItem.kyc_verified));
            h.put("not_for_profit", #Boolean(thisItem.not_for_profit));
            h.put("maturity_e8s_equivalent", #Number(Nat64.toNat(thisItem.maturity_e8s_equivalent)));
            h.put("cached_neuron_stake_e8s", #Number(Nat64.toNat(thisItem.cached_neuron_stake_e8s)));
            h.put("created_timestamp_seconds", #Number(Nat64.toNat(thisItem.created_timestamp_seconds)));
            h.put("aging_since_timestamp_seconds", #Number(Nat64.toNat(thisItem.aging_since_timestamp_seconds)));
            h.put("account", #String(AccountIdentifier.toText(thisItem.account) ));
            h.put("dissolve_state", #Number(Nat64.toNat(switch(Option.get<GT.DissolveState>(thisItem.dissolve_state, #DissolveDelaySeconds(0))){
              case(#DissolveDelaySeconds(x)){x};
              case(#WhenDissolvedTimestampSeconds(x)){x};
            })));
            h.put("dissolve_state_type", #String((switch(Option.get<GT.DissolveState>(thisItem.dissolve_state, #DissolveDelaySeconds(0))){
              case(#DissolveDelaySeconds(x)){"DissolveDelaySeconds"};
              case(#WhenDissolvedTimestampSeconds(x)){"WhenDissolvedTimestampSeconds"};
            })));


          items.add(json.show(#Object(h)));

          return "";
      });

      
      

        return {
          body = Text.encodeUtf8("[" # Text.join(",", items.vals()) # "]");
          headers = [("Content-Type", "application/json")];
          status_code = 200;
          streaming_strategy = null;
        };

      } else {
        return {
          body = Text.encodeUtf8("404 not found");
          headers = [("Content-Type", "text/plain")];
          status_code = 404;
          streaming_strategy = null;
        };
      };
  };


  public shared({ caller }) func call_raw(canister: Principal, functionName: Text, argumentBinary: Blob, cycles: Nat) : async Result.Result<Blob, Text> {
    Debug.print(debug_show(axon) # " " # debug_show(caller) # " " # debug_show(owner));
    assert(caller == owner);

    Debug.print("in call_raw");

    if(cycles > 0){
      Debug.print("adding cycles");
      Cycles.add(cycles);
    };
     
    try{
      Debug.print("trying call");
      #ok(await ExperimentalInternetComputer.call(canister, functionName, argumentBinary));
    } catch(e){
      Debug.print("in error" # Error.message(e));
      #err(Error.message(e));
    };
  };


  /////////////////////////////
  /////////////////////////////
  //ICRC1 implementation
  /////////////////////////////

  let owner_text = Principal.toText(axon);

  let charbuffer = Buffer.Buffer<Char>(3);
  label abbv for(thisChar in owner_text.chars()){
    charbuffer.add(thisChar);
    if(charbuffer.size() == 3){
      break abbv;
    };
  };

   let init_args = {
        name = "Axon " # owner_text;
        symbol = "AX" # Text.fromIter(charbuffer.vals());
        decimals = 0 : Nat8;
        fee = 0;
        max_supply = 100_000_000_000_000_000_000_000;
        initial_balances = [];
        min_burn_amount = 1;

        /// optional value that defaults to the caller if not provided
        minting_account = null;

        advanced_settings = null;
    };

   let icrc1_args : ICRC1.InitArgs = {
        init_args with minting_account = Option.get(
            init_args.minting_account,
            {
                owner = owner;
                subaccount = null;
            },
        );
    };

    stable var token = ICRC1.init(icrc1_args);

    /// Functions for the ICRC1 token standard
    public shared query func icrc1_name() : async Text {
        ICRC1.name(token);
    };

    public shared query func icrc1_symbol() : async Text {
        ICRC1.symbol(token);
    };

    public shared query func icrc1_decimals() : async Nat8 {
        ICRC1.decimals(token);
    };

    public shared query func icrc1_fee() : async ICRC1.Balance {
        ICRC1.fee(token);
    };

    public shared query func icrc1_metadata() : async [ICRC1.MetaDatum] {
        ICRC1.metadata(token);
    };

    public shared query func icrc1_total_supply() : async ICRC1.Balance {
        ICRC1.total_supply(token);
    };

    public shared query func icrc1_minting_account() : async ?ICRC1.Account {
        ?ICRC1.minting_account(token);
    };

    public shared query func icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance {
        ICRC1.balance_of(token, args);
    };

    public shared query func icrc1_supported_standards() : async [ICRC1.SupportedStandard] {
        ICRC1.supported_standards(token);
    };

    public shared ({ caller }) func icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult {
        if(no_transfer == true){
          return #Err(#GenericError({ error_code = 1; message = "This token does not allow transfers" }));
        };

        let result = await ICRC1.transfer(token, args, caller);

        let requests = Buffer.Buffer<(Principal, Nat)>(2);

        switch(result){
          case(#Ok(val)){
            if(args.to.subaccount == null){ //only null subaccounts can be members of the dao
              
              let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode(args.to));
              Debug.print("sending a refresh " # debug_show((args.to.owner, account_balance)));
              requests.add(args.to.owner, account_balance);
              
              
            };
            if(args.from_subaccount == null){ //only null subaccounts can be members of the dao
              let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode({owner = caller; subaccount= null;}));
              Debug.print("sending a refresh " # debug_show((args.to.owner, account_balance)));
              requests.add(caller, account_balance);
            }
          };
          case(_){};
        };

        let axon_service : Axon.Self = actor(Principal.toText(axon));
        
        let thisAxon = axon_service.refreshBalances(axonId, Buffer.toArray(requests));
              

        Debug.print("refresh done ");

        return result;
    };

    public shared ({ caller }) func mint(args : ICRC1.Mint) : async ICRC1.TransferResult {
        Debug.print("in mint in proxy " # debug_show((caller, axon)));
        assert(caller == axon);
        let result = await ICRC1.mint(token, {
          args with
          from_subaccount = ?minting_subaccount}, Principal.fromActor(this));

        let requests = Buffer.Buffer<(Principal, Nat)>(2);


        switch(result){
          case(#Ok(val)){
            if(args.to.subaccount == null){ //only null subaccounts can be members of the dao
              
              let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode(args.to));
              Debug.print("sending a refresh " # debug_show((args.to.owner, account_balance)));
              requests.add(args.to.owner, account_balance);
              
              
            };
          };
          case(_){};
        };

        let axon_service : Axon.Self = actor(Principal.toText(axon));
        
        let thisAxon = axon_service.refreshBalances(axonId, Buffer.toArray(requests));

        return result;
    };

    public shared ({ caller }) func burn(args : {from : ICRC1.Account;
      amount : ?Nat;
      memo : ?Blob;
      created_at_time : ?Nat64;}) : async ICRC1.TransferResult {
        assert(caller == axon);
        if(allow_burn == false){
          return #Err(#GenericError({ error_code = 2; message = "This token does not allow burn" }));
        };
        let result = await ICRC1.burn(token, {from_subaccount = null; amount = switch(args.amount){
          case(null) {ICRC1.balance_of(token, args.from);};
          case(?val) val;
        }; memo= args.memo; created_at_time = args.created_at_time;}, args.from.owner);

        let requests = Buffer.Buffer<(Principal, Nat)>(2);

        switch(result){
          case(#Ok(val)){
          
            if(args.from.subaccount == null){ //only null subaccounts can be members of the dao
              let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode(args.from));
              Debug.print("sending a refresh " # debug_show((args.from.subaccount, account_balance)));
              requests.add(args.from.owner, account_balance);
            }
          };
          case(_){};
        };

        let axon_service : Axon.Self = actor(Principal.toText(axon));
        
        let thisAxon = axon_service.refreshBalances(axonId, Buffer.toArray(requests));


        return result;
    };

    public shared ({ caller }) func mint_burn_batch(args : [BatchCommand]) : async [ICRC1.TransferResult] {
        assert(caller == axon);
        if(Array.find<BatchCommand>(args, func(x : BatchCommand){
          switch(x){
            case(#Burn(val)) return true;
            case(_) return false;
          };
        }) != null){
          if(allow_burn == false){
            return [#Err(#GenericError({ error_code = 2; message = "This token does not allow burn" }))];
          };
        };

        let all_results = Buffer.Buffer<ICRC1.TransferResult>(1);

        let accruedAccounts = Map.new<Principal, Nat>();

        for(thisItem in args.vals()){
          switch(thisItem){
            case(#Mint(args)){
              let result = await ICRC1.mint(token, {
                args with
                from_subaccount = ?minting_subaccount}, Principal.fromActor(this));

              switch(result){
                case(#Ok(val)){
                  if(args.to.subaccount == null){ //only null subaccounts can be members of the dao
                    
                    let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode(args.to));
                    Debug.print("sending a refresh " # debug_show((args.to.owner, account_balance)));
                    ignore Map.put<Principal,Nat>(accruedAccounts, Map.phash, args.to.owner, account_balance);
                    
                    
                  };
                };
                case(_){};
              };

              all_results.add(result);
            };
            case(#Burn(args)){
              let result = await ICRC1.burn(token, {from_subaccount = null; amount = switch(args.amount){
                case(null) {ICRC1.balance_of(token, args.from);};
                case(?val) val;
              }; memo= args.memo; created_at_time = args.created_at_time;}, args.from.owner);
              switch(result){
                case(#Ok(val)){
                
                  if(args.from.subaccount == null){ //only null subaccounts can be members of the dao
                    let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode(args.from));
                    Debug.print("sending a refresh " # debug_show((args.from.subaccount, account_balance)));
                    ignore Map.put<Principal,Nat>(accruedAccounts, Map.phash, args.from.owner, account_balance);
                  }
                };
                case(_){};
              };

              all_results.add(result);
            };
            case(#Balance(args)){
              let balance = ICRC1.balance_of(token, args.owner);
              if(balance != args.amount){
                let result = if(balance > args.amount){
                  
                    await ICRC1.burn(token, {from_subaccount = null; amount = balance - args.amount; memo= args.memo; created_at_time = args.created_at_time;}, args.owner.owner);
                  
                  
                 } else {
                  await ICRC1.mint(token, {to = args.owner; amount = args.amount - balance; memo= args.memo; created_at_time = args.created_at_time;}, args.owner.owner);
                };
              
              
                switch(result){
                  case(#Ok(val)){
                  
                    if(args.owner.subaccount == null){ //only null subaccounts can be members of the dao
                      let account_balance = ICRC1Utils.get_balance(token.accounts, ICRC1Account.encode(args.owner));
                      Debug.print("sending a refresh " # debug_show((args.owner.subaccount, account_balance)));
                      ignore Map.put<Principal,Nat>(accruedAccounts, Map.phash, args.owner.owner, account_balance);
                    }
                  };
                  case(_){};
                };

                all_results.add(result);
              };
            };
          };
        };

        let axon_service : Axon.Self = actor(Principal.toText(axon));

        //need to refresh all accounts 9 at a time
        
        let thisAxon = axon_service.refreshBalances(axonId, Iter.toArray<(Principal, Nat)>(Map.entries<Principal, Nat>(accruedAccounts)));
        

        return all_results.toArray();
        
    };

    // Functions for integration with the rosetta standard
    public shared query func get_transactions(req : ICRC1.GetTransactionsRequest) : async ICRC1.GetTransactionsResponse {
        ICRC1.get_transactions(token, req);
    };

    // Additional functions not included in the ICRC1 standard
    public shared func get_transaction(i : ICRC1.TxIndex) : async ?ICRC1.Transaction {
        await ICRC1.get_transaction(token, i);
    };

    // Deposit cycles into this canister.
    public shared func deposit_cycles() : async () {
        let amount = Cycles.available();
        let accepted = Cycles.accept(amount);
        assert (accepted == amount);
    };

    ///////////////
    /// functions to let axon manage ICRC
    //////////////

    stable var no_transfer = false;
    stable var allow_burn = false;
    stable var axonId = 999999999999999;

    let minting_subaccount = Blob.fromArray([255,34,56,2,    34,5,5,6,    7,8,34,2,    6,7,234,1,    6,167,56,2,    34,5,5,6,    7,8,234,45,    98,124,189,123]);


    //syncs the polices from the axon
    public shared({caller}) func sync_policy() : async Result.Result<Bool,Text>{
      Debug.print("sync policy" # debug_show(axonId));
      assert(caller == axon);
      ignore accept_all_cycles();

      let axon_service : Axon.Self = actor(Principal.toText(axon));

      let thisAxon = await axon_service.axonByWallet(Principal.fromActor(this));
      switch(thisAxon){
        case(null){
          Debug.print("noaxon");
        };
        case(?val){
          Debug.print("haveaxon" # debug_show(val.id));
        }
      };
      

      let a_axon = switch(thisAxon){
        case(null) return #err("no policy found");
        case(?val) val
      };

      token := {
        token with
            var _fee = token._fee;
            var _minted_tokens = token._minted_tokens;
            var _burned_tokens = token._burned_tokens;     
            archive: ICRC1Types.ArchiveData = {
                var canister = token.archive.canister;
                var stored_txs = token.archive.stored_txs;
            };
            minting_account = {
              owner = Principal.fromActor(this);
              subaccount = ?minting_subaccount;
            };
        };
      axonId := a_axon.id;
      no_transfer := a_axon.policy.restrictTokenTransfer;
      allow_burn := a_axon.policy.allowTokenBurn;

      return #ok(true);
    };


    //syncs the ledger from the axon but only once
    stable var is_seeded = false;

    public shared({caller}) func seed_balance() : async Result.Result<Bool,Text>{
      Debug.print("seed balance" # debug_show(axonId));
      if(caller == axon and is_seeded == false){
        ignore accept_all_cycles();

        let axon_service : Axon.Self = actor(Principal.toText(owner));

        let thisLedger = await axon_service.ledger(axonId);

        for(thisItem in thisLedger.vals()){
          let result = await ICRC1.mint(token, {
              from_subaccount = ?minting_subaccount;
              to = {owner = thisItem.0; subaccount = null};
              amount = thisItem.1;
              fee = ?token._fee;
              memo = null;
              created_at_time =null;},
          Principal.fromActor(this));
        };

        is_seeded := true;
      } else {
         return #err("already seeded");
      };

      return #ok(true);
    };

    public shared({caller}) func redenominate(from: Nat, to: Nat) : async Result.Result<Bool,Text>{
      //todo: will break down if number of accounts data > 2MB
      assert(caller == axon);
      ignore accept_all_cycles();

      var change : Int = 0;
      let newBalances = Buffer.Buffer<(Principal, Nat)>(StableTrieMap.size(token.accounts));

      label process for(thisItem in StableTrieMap.entries(token.accounts)){
        let account = switch(ICRC1Account.decode(thisItem.0)){
          case(null){continue process;};
          case(?val){val};
        };
        let newVal = A.scaleByFraction(thisItem.1, to, from);
        if(newVal > thisItem.1){
          //mint
          change += newVal - thisItem.1;
        } else {
          //burn
          change -= thisItem.1 - newVal;
        };
        StableTrieMap.put<Blob,Nat>(
          token.accounts, 
          Blob.equal,
          Blob.hash,
          thisItem.0, 
          newVal);
        if(account.subaccount == null){
          //only notify default accounts
          newBalances.add(account.owner, newVal);
        };
      };

      let index = SB.size(token.transactions) + token.archive.stored_txs;

      SB.add<ICRC1Types.Transaction>(token.transactions, {
        kind = "redenominate";
        mint = if(change > 0){
            token._minted_tokens += Int.abs(change);
            ?{to = token.minting_account; amount = Int.abs(change); memo = null; created_at_time = null;};
          } else {null};
        burn = if(change < 0){
            token._burned_tokens += Int.abs(change);
            ?{from = token.minting_account; amount = Int.abs(change); memo = null; created_at_time = null;};
          } else {null};
        transfer = null;
        index = index;
        timestamp = Nat64.fromNat(Int.abs(Time.now()));
      });

      let axon_service : Axon.Self = actor(Principal.toText(owner));

      let update_axon = axon_service.refreshBalances(axonId, Buffer.toArray(newBalances));

      return #ok(true);
    };


    public shared({caller}) func update_token(request : {
      metadata: ?[(Text, ICRC1Types.Value)];
      _fee: ?Nat;
      decimals: ?Nat8;
      name: ?Text;
      symbol: ?Text;
      max_supply : ?Nat;
      _minted_tokens: ?Nat;
      _burned_tokens: ?Nat;
      permitted_drift : ?Nat;
    }) : async Result.Result<Bool,Text>{
      assert(caller == Principal.fromActor(this)); //only a wallet can update its info from an axon canister command

      ignore accept_all_cycles();
      token := {
        token with
            var _fee = switch(request._fee){
              case(null) token._fee;
              case(?val) val;
            };
            var _minted_tokens = switch(request._minted_tokens){
              case(null) token._minted_tokens;
              case(?val) val;
            };
            var _burned_tokens = switch(request._burned_tokens){
              case(null) token._burned_tokens;
              case(?val) val;
            };  
            archive: ICRC1Types.ArchiveData = {
                var canister = token.archive.canister;
                var stored_txs = token.archive.stored_txs;
            };
            decimals = switch(request.decimals){
              case(null) token.decimals;
              case(?val) val;
            };  
            name = switch(request.name){
              case(null) token.name;
              case(?val) val;
            };  
            max_supply = switch(request.max_supply){
              case(null) token.max_supply;
              case(?val) val;
            };  
            permitted_drift = switch(request.permitted_drift){
              case(null) token.permitted_drift;
              case(?val) val;
            };
            symbol = switch(request.symbol){
              case(null) token.symbol;
              case(?val) val;
            };
        };
      return #ok(true);
    };

    public shared({caller}) func force_refresh_balance(request : [Principal]) : async Result.Result<Bool,Text>{
      assert(caller == Principal.fromActor(this)); //only a wallet can update its info from an axon canister command

      //todo: will break down if number of accounts data > 2MB
      ignore accept_all_cycles();

      var change : Int = 0;
      let newBalances = Buffer.Buffer<(Principal, Nat)>(StableTrieMap.size(token.accounts));
      
      label process for(thisItem in request.vals()){
        let encodedAccount = ICRC1Account.encode({owner= thisItem; subaccount = null});
        switch(StableTrieMap.get(token.accounts, Blob.equal, Blob.hash, encodedAccount)){
          case(null){
            newBalances.add((thisItem, 0));
          };
          case(?val){
            newBalances.add((thisItem, val));
          }
        };
      };
      let axon_service : Axon.Self = actor(Principal.toText(owner));

      let update_axon = axon_service.refreshBalances(axonId, Buffer.toArray(newBalances));

      return #ok(true);
    };
}
