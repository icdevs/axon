import { HttpAgent } from "@dfinity/agent";

export const HOST =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local" || process.env.NEXT_PUBLIC_DFX_NETWORK === "voice"
    ? "http://localhost:8080"
    : "https://icp-api.io/";

export const IDENTITY_PROVIDER =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"
    ? "http://ryjl3-tyaaa-aaaaa-aaaba-cai.localhost:8000"
    : undefined;

export const defaultAgent = new HttpAgent({
  host: HOST,
});

export const CANISTER_NAME = {
  GOVERNANCE_CANISTER: "GOVERNANCE_CANISTER",
  AXON_CANISTER: "AXON_CANISTER",
};
