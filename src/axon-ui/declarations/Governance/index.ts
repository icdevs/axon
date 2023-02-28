import { Actor, ActorSubclass } from "@dfinity/agent";
import { idlFactory } from "./Governance.did";
import _SERVICE from "./Governance.did.d";
export { idlFactory };

export const canisterId = "rrkah-fqaaa-aaaaa-aaaaq-cai";

export const createActor = (canisterId, agent): ActorSubclass<_SERVICE> => {
  return Actor.createActor(idlFactory, {
    agent,
    canisterId,
  });
};
