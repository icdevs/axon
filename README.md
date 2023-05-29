<p align="center">
  <img width="400" height="200" src="./src/axon-ui/public/img/logo.svg">
</p>
<p align="center">
<i>The function of the axon is to transmit information to different neurons - <a href="https://en.wikipedia.org/wiki/Axon" target="_blank">Wikipedia</a></i></p>

---

Axon is a multi-user, multi-neuron management canister.

This repo is a fork of the original <a href="https://github.com/FloorLamp/axon" target="_blank">Axon project</a>, created and sponsored by <a href="https://icdevs.org/" target="_blank">ICDevs.org</a>.

## Overview

- An Axon canister controls one or more neurons
- Axons can have one or more owners
- An approval policy can be set, eg. 3 out of 5 owners required to approve an action
- Requests like `ManageNeuron` are sent to Axon, which queues them for approval
- A snapshot of owners and current policy is stored with each request
- Once the policy conditions are met, the request is forwarded to all controlled neurons
- Axons can be public and expose all neuron data

## Admins

Only Admins can create new Axons. The Admin role can be granted to or removed from principals only by the Master Admin. The Master Admin is the principle that deploys the parent Axon dapp canister.

You may want to add your wallet principal:

dfx canister --network ic call Axon add_admin '(principal "k3gvh-4fgvt-etjfk-dfpfc-we5bp-cguw5-6rrao-65iwb-ttim7-tt3bc-6qe")'

## Deploying Axon dapp
*(Principal of deploying identity becomes Master Admin)*

Deploy an Axon dapp :

```sh
cd src/axon-ui
```

Follow the instructions to add the Psycadelic context as a github package registry: https://github.com/Psychedelic/plug-inpage-provider#-installation

npm i
npm run build
```
```sh
npm run export
```
```sh
cd ../..
```
```sh
dfx deploy --network ic
```

## Deploying a child Axon
*(must be an Admin)*

Deploy an Axon canister:

```sh
dfx deploy Axon --argument 'record {owner= (principal "your-principal-here"); visibility= variant{Public}}'
```

## Testing locally

*(Principal of deploying identity becomes Master Admin)*

Deploy an Axon dapp :

```sh
cd src/axon-ui
```

Follow the instructions to add the Psycadelic context as a github package registry: https://github.com/Psychedelic/plug-inpage-provider#-installation

npm i
npm run build_local
```
```sh
npm run export_local
```
```sh
cd ../..
```
```sh
dfx deploy --network local
```

Currently, canisters cannot control neurons. It is only possible to add the Axon canister as a hot key for neurons, so only commands like `Follow` and `RegisterVote` will succeed.


# Documentation for Axon.mo

## Public queries

### `is_admin(p: Principal): async Bool`

Checks if the specified principal is an admin on the axon head canister.

#### Parameters

- `p` (type: `Principal`): The principal to check.

#### Returns

- (type: `async Bool`): Returns `true` if the principal is an admin, otherwise `false`.

### `get_admins(): async Array<Principal>`

Returns a list of all the admins.

#### Returns

- (type: `async Array<Principal>`): An array containing all the admins.

### `count(): async Nat`

Retrieves the number of axons.

#### Returns

- (type: `async Nat`): The count of axons.

### `topAxons(): async Array<AxonPublic>`

Retrieves the top axons based on their total stake.

#### Returns

- (type: `async Array<AxonPublic>`): An array of axons sorted by total stake in descending order.

### `axonById(id: Nat): async AxonPublic`

Retrieves the public information of an axon by ID.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async AxonPublic`): The public information of the axon.

### `axonByWallet(id: Principal): async ?AxonPublic`

Retrieves the public information of an axon by wallet address.  You can use this if you know your Axon Proxy and want to find the axon id that controls that proxy.

#### Parameters

- `id` (type: `Principal`): The wallet principal of the axon.

#### Returns

- (type: `async ?AxonPublic`): The public information of the axon, or null if not found.

### `axonStatusById(id: Nat): async CanisterStatusResult`

Retrieves the status of an axon by ID.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async CanisterStatusResult`): The status of the axon.

### `getNeuronIds(id: Nat): async Array<Nat64>`

Retrieves the neuron IDs associated with an axon.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async Array<Nat64>`): An array of neuron IDs.

### `balanceOf(id: Nat, principal: ?Principal): async Nat`

Retrieves the balance for a principal on a given axon for a specific principal or caller.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.
- `principal` (type: `?Principal`): Optional. The principal for which to retrieve the balance. If null, the caller's balance is retrieved.

#### Returns

- (type: `async Nat`): The balance of the axon for the specified principal or caller.  This is the snap shot blance.  "Source of truth" balances should be checked on the axon proxy using icrc1_balance_of

### `ledger(id: Nat): async Array<LedgerEntry>`

Retrieves the ledger entries of an axon by ID.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async Array<LedgerEntry>`): An array of ledger entries sorted in descending order by balance.  This is a shapshot of the holders of the Axon token. It should not be used as a source of truth.

### `myAxons(): async Array<AxonPublic>`

Retrieves the axons where the caller has a non-zero balance.

#### Returns

- (type: `async Array<AxonPublic>`): An array of axons where the caller has a balance.

### `getNeurons(id: Nat): async NeuronsResult`

Retrieves the neurons associated with an axon.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async NeuronsResult`): The result containing the neurons associated with the axon.

### `getProposalById(axonId: Nat, proposalId: Nat): async Result<AxonProposalPublic>`

Retrieves a single proposal by ID.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `proposalId` (type: `Nat`): The ID of the proposal.

#### Returns

- (type: `async Result<AxonProposalPublic>`): The result containing the public information of the proposal.

### `getActiveProposals(id: Nat): async ProposalResult`

Retrieves all active proposals of an axon.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async ProposalResult`): The result containing the public information of the active proposals.

### `getAllProposals(id: Nat, before: ?Nat): async ProposalResult`

Retrieves the last 100 proposals of an axon, optionally before the specified ID.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.
- `before` (type: `?Nat`): Optional. The ID of the proposal to retrieve proposals before.

#### Returns

- (type: `async ProposalResult`): The result containing the public information of the proposals.

### `getMotionProposals(id: Nat): async ProposalResult`

Retrieves all motion proposals of an axon.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async ProposalResult`): The result containing the public information of the motion proposals.

## Public Updates

### `add_admin(p: Principal): async void`

Adds the specified principal as an admin.

#### Parameters

- `p` (type: `Principal`): The principal to add as an admin.

### `cycles(): async Nat`

Retrieves the current balance of cycles.

#### Returns

- (type: `async Nat`): The current balance of cycles.

### `updateSettings(canisterId: Principal, manager: Principal): async void`

Updates the controller of an axon. This is needed for deletion purposes.

#### Parameters

- `canisterId` (type: `Principal`): The canister ID of the axon.
- `manager` (type: `Principal`): The new manager's principal.

### `update_master(p: Principal): async void`

Changes the master.

#### Parameters

- `p` (type: `Principal`): The new master's principal.

### `remove_admin(p: Principal): async void`

Removes the specified principal as an admin.

#### Parameters

- `p` (type: `Principal`): The principal to remove as an admin.

### `private _mint(caller: Principal, axonId: Nat, p: Principal, a: Nat): async* Result<AxonCommandExecution>`

Mints a specified amount of tokens for a recipient. Creates the equivalent of an mint proposal and executes it.  You must have a minting privileges. A message will be sent to the proxy wallet to actually mint the tokens and then the proxy will update the balance on the Axon head.

#### Parameters

- `caller` (type: `Principal`): The caller's principal.
- `axonId` (type: `Nat`): The ID of the axon.
- `p` (type: `Principal`): The recipient's principal.
- `a` (type: `Nat`): The amount of tokens to mint.

#### Returns

- (type: `async* Result<AxonCommandExecution>`): The result of the axon command execution.


### `mint(axonId: Nat, p: Principal, a: Nat): async Result<AxonCommandExecution>`

Mints a specified amount of tokens for a recipient.  Must be the minting canister or principal

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `p` (type: `Principal`): The recipient's principal.
- `a` (type: `Nat`): The amount of tokens to mint.

#### Returns

- (type: `async Result<AxonCommandExecution>`): The result    * of the axon command execution.

### `mint_batch(request: Array<[Nat, Principal, Nat]>): async Array<[(Nat, Principal, Nat), Result<AxonCommandExecution>]>`

Mints a batch of tokens for multiple recipients.

#### Parameters

- `request` (type: `Array<[Nat, Principal, Nat]>`): An array of tuples, each containing the axon ID, recipient's principal, and amount of tokens to mint.

#### Returns

- (type: `async Array<[(Nat, Principal, Nat), Result<AxonCommandExecution>]>`): An array of tuples, each containing the request details and the result of the axon command execution.

### `burn(axonId: Nat, p: Principal, a: Nat): async Result<AxonCommandExecution>`

Burns a specified amount of tokens owned by a recipient. Burns must be allowed.  A message will be sent to the proxy to burn the tokens. Balance will be updated by the proxy wallet if the burn is allowed.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `p` (type: `Principal`): The owner's principal.
- `a` (type: `Nat`): The amount of tokens to burn.

#### Returns

- (type: `async Result<AxonCommandExecution>`): The result of the axon command execution.

### `burn_batch(request: Array<[Nat, Principal, Nat]>): async Array<[(Nat, Principal, Nat), Result<AxonCommandExecution>]>`

Burns a batch of tokens owned by multiple recipients.

#### Parameters

- `request` (type: `Array<[Nat, Principal, Nat]>`): An array of tuples, each containing the axon ID, owner's principal, and amount of tokens to burn.

#### Returns

- (type: `async Array<[(Nat, Principal, Nat), Result<AxonCommandExecution>]>`): An array of tuples, each containing the request details and the result of the axon command execution.

### `upgradeProxy(): async Array<Result<Bool, Text>>`

Upgrades a proxy to the new actor type.  This should be called once for each upgrade to upgrade all the proxy canisters one by one to the new actor.

#### Returns

- (type: `async Array<Result<Bool, Text>>`): An array of results indicating the success or failure of the upgrade process for each axon.

### `wallet_receive(): async Nat`

Accepts cycles to the wallet.

#### Returns

- (type: `async Nat`): The amount of accepted cycles.

### `recycle_cycles(axonId: Nat, floor: Nat): async Nat`

Accepts cycles and recycles them for an axon.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `floor` (type: `Nat`): The floor value.

#### Returns

- (type: `async Nat`): The amount of accepted cycles.

### `transfer(id: Nat, dest: Principal, amount: Nat): async Result<()>`

Transfers tokens from one axon to another.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.
- `dest` (type: `Principal`): The destination principal.
- `amount` (type: `Nat`): The amount of tokens to transfer.

#### Returns

- (type: `async Result<()>`): The result of the token transfer operation.

### `create(init: Initialization): async Result<AxonPublic>`

Creates a new axon.

#### Parameters

- `init` (type: `Initialization`): The initialization parameters for the axon.

#### Returns

- (type: `async Result<AxonPublic>`): The result containing the public information of the created axon.

### `propose(request: NewProposal): async Result<AxonProposalPublic>`

Submits a new proposal for an axon.

#### Parameters

- `request` (type: `NewProposal`): The new proposal request.

#### Returns

- (type: `async Result<AxonProposalPublic>`): The result containing the public information of the created proposal.

### `vote(request: VoteRequest): async Result<()>`

Votes on an active proposal.

#### Parameters

- `request` (type: `VoteRequest`): The vote request.

#### Returns

- (type: `async Result<()>`): The result of the vote operation.

### `cancel(axonId: Nat, proposalId: Nat): async Result<AxonProposalPublic>`

Cancels an active proposal created by the caller.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `proposalId` (type: `Nat`): The ID of the proposal.

#### Returns

- (type: `async Result<AxonProposalPublic>`): The result containing the public information of the canceled proposal.

### `execute(axonId: Nat, proposalId: Nat): async Result<AxonProposalPublic>`

Queues a proposal for execution.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `proposalId` (type: `Nat`): The ID of the proposal.

#### Returns

- (type: `async Result<AxonProposalPublic>`): The result containing the public information of the queued proposal.

### `sync(id: Nat): async NeuronsResult`

Calls `list_neurons()` and saves the list of neurons controlled by the axon's proxy.

#### Parameters

- `id` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async NeuronsResult`): The result containing the list of neurons and the timestamp.

### `refreshBalances(axonId: Nat, accounts: Array<{account: Principal, balance: Nat}>): async [Result<Bool>]`

Refreshes the balances of the specified accounts in the axon's ledger.  This can only be called by the proxy wallet and is used to keep the axon head in sync with the proxy.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `

accounts` (type: `Array<{account: Principal, balance: Nat}>`): The accounts and their updated balances.

#### Returns

- (type: `async [Result<Bool>]`): The results of the balance refresh operation.

### `cleanup(axonId: Nat): async Result<()>`

Updates the proposal statuses and moves them from active to all if needed. Called by the `sync` function.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.

#### Returns

- (type: `async Result<()>`): The result of the cleanup operation.

### `private _doExecute(axonId: Nat, proposal: AxonProposal): async AxonProposalPublic`

Executes an accepted proposal.

#### Parameters

- `axonId` (type: `Nat`): The ID of the axon.
- `proposal` (type: `AxonProposal`): The proposal to execute.

#### Returns

- (type: `async AxonProposalPublic`): The public information of the executed proposal.


### Helper Functions

#### `tokenTransfersAllowed(id: Nat): Bool`

Returns true if the policy of an axon allows token transfers by members.

#### `isAuthed(principal: Principal, ledger: Ledger): Bool`

Returns true if the principal holds a balance in the ledger or if it's this canister.

#### `neuronIdsFromInfos(id: Nat): Array<Nat64>`

Returns the neuron IDs from the stored neuron infos.

#### `getAxonPublic(axon: AxonFull): AxonPublic`

Returns the public information of the axon with its own balance.

#### `secsToNanos(s: Int): Int`

Converts seconds to nanoseconds.

#### `clamp(n: Int, lower: Int, upper: Int): Int`

Clamps a number within a specified range.

#### `makeError(e: Error): Error`

Creates an error object from an error.

# Documentation for Proxy.mo (The wallet canister)

The Proxy wallet contract is responsible for managing an ICRC1 token implementation and providing various functionalities for interacting with the token.  If also allows the users to make requests for call_raw calls so that the Axon Proxy Wallet can call other services.

### Public Functions

#### `metrics(): {axon: Principal, archive: Principal}`

Retrieves the metrics of the Proxy wallet contract.

#### `recycle_cycles(caller: Principal, floor: Nat): Nat`

Recycles cycles from the Proxy wallet contract.

#### `list_neurons(): GT.ListNeuronsResponse`

Calls the list_neurons() function and saves the list of neurons that this canister controls.

#### `manage_neuron(args: GT.ManageNeuron): GT.ManageNeuronResponse`

Manages a neuron by calling the manage_neuron() function.

#### `call_raw(canister: Principal, functionName: Text, argumentBinary: Blob, cycles: Nat): Result.Result<Blob, Text>`

Calls a canister function with raw parameters.

### ICRC1 Token

- **`icrc1_name() : async Text`**: Retrieves the name of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_symbol() : async Text`**: Retrieves the symbol of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_decimals() : async Nat8`**: Retrieves the decimals of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_fee() : async ICRC1.Balance`**: Retrieves the fee of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_metadata() : async [ICRC1.MetaDatum]`**: Retrieves the metadata of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_total_supply() : async ICRC1.Balance`**: Retrieves the total supply of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_minting_account() : async ?ICRC1.Account`**: Retrieves the minting account of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance`**: Retrieves the balance of an ICRC1 account in the Proxy wallet contract.
- **`icrc1_supported_standards() : async [ICRC1.SupportedStandard]`**: Retrieves the supported standards of the ICRC1 token in the Proxy wallet contract.
- **`icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult`**: Transfers ICRC1 tokens in the Proxy wallet contract.

## Management Functions

- **`mint(args : ICRC1.Mint) : async ICRC1.TransferResult`**: Mints new ICRC1 tokens in the Proxy wallet contract.
- **`burn(args : ICRC1.Burn) : async ICRC1.TransferResult`**: Burns  ICRC1 tokens in the Proxy wallet contract.
- **`get_transactions(req: ICRC1.GetTransactionsRequest): async ICRC1.GetTransactionsResponse`**

  Retrieves transactions of the ICRC1 token in the Proxy wallet contract.

- **`get_transaction(i: ICRC1.TxIndex): async ?ICRC1.Transaction`**

  Retrieves a transaction of the ICRC1 token in the Proxy wallet contract.

- **`deposit_cycles(): async`**

  Deposits cycles into the Proxy wallet contract.

- **`sync_policy(): async Result.Result<Bool, Text>`**

  Synchronizes the policies from the axon.

- **`seed_balance(): async Result.Result<Bool, Text>`**

  Seeds the balance from the axon but only once.

- **`redenominate(from: Nat, to: Nat): async Result.Result<Bool, Text>`**

  Redenominates the token balance.

- **`update_token(request: Object): async Result.Result<Bool, Text>`**

  Updates the token information.

- **`force_refresh_balance(request: Array<Principal>): async Result.Result<Bool, Text`>**

  Forces a refresh of balance for specified accounts.

## Release Notes

### v2.1.0

* moved system of record for balances to Proxy canister
* added ICRC-1 to Proxy Canister
* added mint_batch and burn_batch to axon for large scale burning/minting - warning - will be processed in series with awaits between each burn/mint batch of 10 - return order not guaranteed

### v2.0.3

* fixed voting bug

### v2.0.2

* fixed admin bug
* fixed UI bug

### v2.0.1

* Fixed Bug that would not allow execution if not immediate.
* Allowed step on percentage up to .000001
* Fixed a bug where anyone could update the canister settings of a child axon.
* Added a note and cycles to Canister calls
* Added the ability to upgrade proxies via upgrade pathway.
* Added migration framework