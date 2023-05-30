import CanisterIds from "../../canister_ids.json" assert { type: "json" };
import nextTranspile from "next-transpile-modules";

const withTM = nextTranspile([
  "@connect2ic/core",
  "@connect2ic/react",
  "@astrox/connection",
]);

const AXON_CANISTER_ID =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"
    ? await import("../../.dfx/local/canister_ids.json", {
        assert: { type: "json" },
      }).then((res) => res.default.Axon.local)
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "staging"
    ? CanisterIds.staging.ic
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "testic"
    ? CanisterIds.AxonTest.ic
    : CanisterIds.Axon.ic;

console.log(process.env.NEXT_PUBLIC_DFX_NETWORK);
console.log(`NEXT_PUBLIC_DFX_NETWORK=${process.env.NEXT_PUBLIC_DFX_NETWORK}`);
console.log(`AXON_CANISTER_ID=${AXON_CANISTER_ID}`);

export default withTM({
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    // !! WARN !!
    ignoreBuildErrors: true,
  },
  env: {
    AXON_CANISTER_ID,
    LOGO_ICON: "logo.svg",
    GLOBAL_STYLES: "globals.css",
    PAGE_TITLE: "ICDevs Governance Tool",
  },
  async rewrites() {
    return [
      {
        source: "/:path*",
        destination: "/",
      },
    ];
  },
});
