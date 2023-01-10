const CanisterIds = require("../../canister_ids.json");

const AXON_CANISTER_ID =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"
    ? require("../../.dfx/local/canister_ids.json").Axon.local
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "staging"
    ? CanisterIds.staging.ic
    : CanisterIds.Axon.ic;
console.log(`NEXT_PUBLIC_DFX_NETWORK=${process.env.NEXT_PUBLIC_DFX_NETWORK}`);
console.log(`AXON_CANISTER_ID=${AXON_CANISTER_ID}`);

module.exports = {
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
    PAGE_TITLE: "ICDEV Governance Tool",
  },
  async rewrites() {
    return [
      {
        source: '/:path*',
        destination: '/',
      },
    ];
  },
};
