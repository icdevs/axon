import { HttpAgent } from "@dfinity/agent";
import { canisterId, createActor } from "../declarations/Governance";

export const HOST =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local" || process.env.NEXT_PUBLIC_DFX_NETWORK === "voice"
    ? "http://localhost:8080"
    : "https://ic0.app";

export const IDENTITY_PROVIDER =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"
    ? "http://ryjl3-tyaaa-aaaaa-aaaba-cai.localhost:8000"
    : undefined;

export const defaultAgent = new HttpAgent({
  host: HOST,
});

export const governance = createActor(canisterId, defaultAgent);
