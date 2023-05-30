import { HttpAgent } from "@dfinity/agent";
import { canisterId, createActor } from "../declarations/Governance";

export const HOST =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"
    ? "http://localhost:8000"
    : "https://icp-api.io/";

export const defaultAgent = new HttpAgent({
  host: HOST,
});

export const CANISTER_NAME = {
  GOVERNANCE_CANISTER: "GOVERNANCE_CANISTER",
  AXON_CANISTER: "AXON_CANISTER",
};
