import Map_lib "mo:map_7_0_0/Map"; 
import Set_lib "mo:map_7_0_0/Set"; 
import SB_lib "mo:stablebuffer_0_2_0/StableBuffer"; 
import GT "../../GovernanceTypes"; 

import Buffer "mo:base/Buffer"; 
import Result "mo:base/Result"; 
import Error "mo:base/Error"; 
import ICRC1 "mo:icrc1/ICRC1"; 

import v2_0_1 "../v002_000_001/types";

module {
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  

  public let Map = Map_lib;
  public let Set = Set_lib;
  public let SB = SB_lib;

  public type Error = v2_0_1.Error;

  public type Result<T> = Result.Result<T, Error>;

  public type ProposalResult = Result<[AxonProposalPublic]>;

  public type Initialization = {
    name: Text;
    ledgerEntries: [LedgerEntry];
    visibility: Visibility;
    policy: Policy;
  };

  public type VoteRequest = v2_0_1.VoteRequest;

  public type NeuronsResult = v2_0_1.NeuronsResult;

  public type NewProposal = v2_0_1.NewProposal;

  //admins
  public type UpgradeData = v2_0_1.UpgradeData;

  public type MintBurnBatchCommand =  {
    #Mint: {
      to : ICRC1.Account;
      amount : Nat;
      memo : ?Blob;
      created_at_time : ?Nat64;};
    #Burn: {
      from : ICRC1.Account;
      amount : ?Nat;
      memo : ?Blob;
      created_at_time : ?Nat64;};
    #Balance: {
      owner : ICRC1.Account;
      amount : Nat;
      memo : ?Blob;
      created_at_time : ?Nat64;};
  };

  public type Proxy = actor {
    list_neurons : shared () -> async GT.ListNeuronsResponse;
    manage_neuron : shared GT.ManageNeuron -> async GT.ManageNeuronResponse;
    call_raw : shared (Principal, Text, Blob, Nat) -> async Result.Result<Blob,Text>;
    mint_burn_batch : (args : [MintBurnBatchCommand]) -> async [ICRC1.TransferResult];
    recycle_cycles : shared (Principal, Nat) -> async Nat; 
  };

  public type Visibility = v2_0_1.Visibility;
  public type LedgerEntry = v2_0_1.LedgerEntry;

  public type Policy = v2_0_1.Policy;

  // Minimum threshold of votes required
  public type Threshold = v2_0_1.Threshold;

  public type Vote = v2_0_1.Vote;

  public type Ballot = {
    var voted_by: ?Principal;
    principal: Principal;
    votingPower: Nat;
    var vote: ?Vote;
  };

  public type BallotPublic = {
    voted_by: ?Principal;
    principal: Principal;
    votingPower: Nat;
    vote: ?Vote;
  };

  public type Votes = v2_0_1.Votes;

  public type Motion = v2_0_1.Motion;

  public type MintBurnBatchProposal = { 
        #Mint: {amount: Nat; owner: ?Principal};
        #Burn: {amount: ?Nat; owner: Principal};
        #Balance: {amount: Nat; owner: Principal};
      };

  public type AxonCommandRequest = {
    #SetPolicy: Policy;
    #AddMembers: [Principal];
    #RemoveMembers: [Principal];
    #AddMinters: [Principal];
    #RemoveMinters: [Principal];
    #SetVisibility: Visibility;
    #Motion: Motion;

    //---- Token functions

    /*
      Change supply by multiplying each balance by `to`, then dividing by `from`. Rounds down.

      Example:
      from=10, to=1
        Total=100, A=81 (81%), B=10 (10%), C=9 (9%)
      becomes
        Total=9, A=8 (88.8%), B=1 (11.1%), C=0
    */
    #Redenominate: { from: Nat; to: Nat };

    // Mints new tokens to the principal if specified, or Axon itself otherwise
    #Mint: { amount: Nat; recipient: ?Principal };

    

    // Burns existing tokens owned by the principal specified
    #Burn: { amount: Nat; owner: Principal };

    #Mint_Burn_Batch: [{ 
        #Mint: {amount: Nat; owner: ?Principal};
        #Burn: {amount: ?Nat; owner: Principal};
        #Balance: {amount: Nat; owner: Principal};
      }
    ];

    #BurnAll: { owner: Principal };

    // Transfers tokens from Axon to the specified principal
    #Transfer: { amount: Nat; recipient: Principal };
  };

  public type AxonCommandExecution = v2_0_1.AxonCommandExecution;
  
  public type AxonCommandResponse = Result<AxonCommandExecution>;

  public type NeuronCommandRequest = v2_0_1.NeuronCommandRequest;

  public type ManageNeuronResponseOrProposal = v2_0_1.ManageNeuronResponseOrProposal;
  public type NeuronCommandResponse = (Nat64, [ManageNeuronResponseOrProposal]);

  public type CanisterCommandResponse = v2_0_1.CanisterCommandResponse;

  public type CanisterCommandRequest = v2_0_1.CanisterCommandRequest;


  public type AxonCommand = (AxonCommandRequest, ?AxonCommandResponse);
  public type NeuronCommand = v2_0_1.NeuronCommand;
  public type CanisterCommand = v2_0_1.CanisterCommand;

  public type ProposalType = v2_0_1.ProposalType;

  public type Status = v2_0_1.Status;

  public type AxonProposal = {
    id: Nat;
    ballots: Map.Map<Principal, Ballot>;
    totalVotes: Votes;
    timeStart: Int;
    timeEnd: Int;
    creator: Principal;
    proposal: ProposalType;
    status: SB.StableBuffer<Status>;
    policy: Policy;
  };

  public type AxonProposalPublic = {
    id: Nat;
    ballots: [BallotPublic];
    totalVotes: Votes;
    timeStart: Int;
    timeEnd: Int;
    creator: Principal;
    proposal: ProposalType;
    status: [Status];
    policy: Policy;
  };

  public type Neurons = v2_0_1.Neurons;

  public type AxonFull = {
    id: Nat;
    proxy: Proxy;
    name: Text;
    visibility: Visibility;
    var supply: Nat;
    ledger: Ledger;
    policy: Policy;
    neurons: ?Neurons;
    totalStake: Nat;
    allProposals: SB.StableBuffer<AxonProposal>;
    activeProposals: SB.StableBuffer<AxonProposal>;
    delegations_by_owner: Map.Map<Principal,Principal>;
    delegations_by_delegate: Map.Map<Principal, Set.Set<Principal>>;
    var lastProposalId: Nat;
  };

   // Publicly exposed Axon that includes treasury balance, total neuron stake, and token holders
  public type AxonPublic = {
    id: Nat;
    proxy: Proxy;
    name: Text;
    visibility: Visibility;
    supply: Nat;
    policy: Policy;
    balance: Nat;
    totalStake: Nat;
    tokenHolders: Nat;
  };

  public type Ledger = v2_0_1.Ledger;

  public type AdminInterface = {
        

        //  Check if a principal is an admin.
        isAdmin : (state: State, p : Principal) -> Bool;

        //  Add a new principal as admin.
        //  @auth : Admin
        addAdmin : (state: State, p : Principal, caller : Principal) -> ();

        //  Remove a principal from the list of admins. 
        //  @auth : admin
        removeAdmin : (state: State, p : Principal, caller : Principal) -> ();

        // Get the list of admins.
        getAdmins : (state: State) -> [Principal];
    };

  public type State = {
    // this is the data you previously had as stable variables inside your actor class
    var axons : SB.StableBuffer<AxonFull>;
    var admins : SB.StableBuffer<Principal>;
    var creator : Principal;
  };
};
