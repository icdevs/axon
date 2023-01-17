import Map_lib "mo:map_7_0_0/Map"; 
import SB_lib "mo:stablebuffer_0_2_0/StableBuffer"; 
import GT "../../GovernanceTypes"; 

import Buffer "mo:base/Buffer"; 
import Result "mo:base/Result"; 
import Error "mo:base/Error"; 

import v2_0_0 "../v002_000_000/axon_types";

module {
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  

  public let Map = Map_lib;
  public let SB = SB_lib;

  public type Error = {
    #NotAllowedByPolicy;
    #Unauthorized;
    #InvalidProposal;
    #NotFound;
    #ProposalNotFound;
    #NoNeurons;
    #CannotExecute;
    #NotProposer;
    #InsufficientBalanceToPropose;
    #CannotVote;
    #AlreadyVoted;
    #InsufficientBalance;
    #GovernanceError: GT.GovernanceError;
    #Error: { error_message : Text; error_type : Error.ErrorCode };
  };

  public type Result<T> = Result.Result<T, Error>;

  public type ProposalResult = Result<[AxonProposalPublic]>;

  public type Initialization = {
    name: Text;
    ledgerEntries: [LedgerEntry];
    visibility: Visibility;
    policy: Policy;
  };

  public type VoteRequest = v2_0_0.VoteRequest;

  public type NeuronsResult = v2_0_0.NeuronsResult;

  public type NewProposal = {
    axonId: Nat;
    durationSeconds: ?Nat;
    timeStart: ?Int;
    proposal: ProposalType;
    execute: ?Bool;
  };


  //admins
  public type UpgradeData = {
        admins : [Principal];
    };

  public type Proxy = actor {
    list_neurons : shared () -> async GT.ListNeuronsResponse;
    manage_neuron : shared GT.ManageNeuron -> async GT.ManageNeuronResponse;
    call_raw : shared (Principal, Text, Blob, Nat) -> async Result.Result<Blob,Text>;
    recycle_cycles : shared (Principal, Nat) -> async Nat; 
  };

  public type Visibility = { #Private; #Public };
  public type LedgerEntry = (Principal, Nat);

  public type Policy = {
    proposers: { #Open; #Closed: [Principal] };
    proposeThreshold: Nat;
    acceptanceThreshold: Threshold;
    allowTokenBurn: Bool;
    restrictTokenTransfer: Bool;
    minters: {#None; #Minters:[Principal]};
  };

  // Minimum threshold of votes required
  public type Threshold = {
    #Percent: { percent: Nat; quorum: ?Nat }; // proportion times 1e8, ie. 100% = 1e8
    #Absolute: Nat;
  };

  public type Vote = {
    #Yes;
    #No;
  };

  public type Ballot = {
    principal: Principal;
    votingPower: Nat;
    vote: ?Vote;
  };

  public type Votes = {
    notVoted: Nat;
    yes: Nat;
    no: Nat;
  };

  public type Motion = {
    title: Text;
    url: Text;
    body: Text;
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

    // Transfers tokens from Axon to the specified principal
    #Transfer: { amount: Nat; recipient: Principal };
  };
  public type AxonCommandExecution = {
    #Ok;
    #SupplyChanged: { from: Nat; to: Nat };
    #Transfer: {
      receiver: Principal;
      amount: Nat;
      senderBalanceAfter: Nat;
    };
  };
  public type AxonCommandResponse = Result<AxonCommandExecution>;

  public type NeuronCommandRequest = {
    neuronIds: ?[Nat64];
    command: GT.Command;
  };

  public type ManageNeuronResponseOrProposal = {
    #ManageNeuronResponse: Result<GT.ManageNeuronResponse>;
    #ProposalInfo: Result<?GT.ProposalInfo>;
  };
  public type NeuronCommandResponse = (Nat64, [ManageNeuronResponseOrProposal]);

  public type CanisterCommandResponse = {
    #reply : Blob;
    #error : Text;
  };

  public type CanisterCommandRequest = {
    canister : Principal;
    functionName : Text;
    argumentBinary : Blob;
    note: Text;
    cycles: Nat;
  };


  public type AxonCommand = (AxonCommandRequest, ?AxonCommandResponse);
  public type NeuronCommand = (NeuronCommandRequest, ?[NeuronCommandResponse]);
  public type CanisterCommand = (CanisterCommandRequest, ?CanisterCommandResponse);

  public type ProposalType = {
    #AxonCommand: AxonCommand;
    #NeuronCommand: NeuronCommand;
    #CanisterCommand: CanisterCommand;
  };

  public type Status = {
    #Created: Int;
    #Active: Int;
    #Accepted: Int;
    #ExecutionQueued: Int;
    #ExecutionStarted: Int;
    #ExecutionTimedOut: Int;
    #ExecutionFinished: Int;
    #Rejected: Int;
    #Expired: Int;
    #Cancelled: Int;
  };

  public type AxonProposal = {
    id: Nat;
    ballots: SB.StableBuffer<Ballot>;
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
    ballots: [Ballot];
    totalVotes: Votes;
    timeStart: Int;
    timeEnd: Int;
    creator: Principal;
    proposal: ProposalType;
    status: [Status];
    policy: Policy;
  };

  public type Neurons = {
    response: GT.ListNeuronsResponse;
    timestamp: Int;
  };

  public type AxonFull = {
    id: Nat;
    proxy: Proxy;
    name: Text;
    visibility: Visibility;
    supply: Nat;
    ledger: Ledger;
    policy: Policy;
    neurons: ?Neurons;
    totalStake: Nat;
    allProposals: SB.StableBuffer<AxonProposal>;
    activeProposals: SB.StableBuffer<AxonProposal>;
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

  public type Ledger = Map.Map<Principal, Nat>;

  public type AdminInterface = {
        

        //  Check if a principal is an admin.
        isAdmin : (state: State, p : Principal) -> Bool;

        //  Add a new principal as admin.
        //  @auth : Admin
        addAdmin : (state: State,p : Principal, caller : Principal) -> ();

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
