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
