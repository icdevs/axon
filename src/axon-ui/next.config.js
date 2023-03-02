const CanisterIds = require("../../canister_ids.json");

const AXON_CANISTER_ID =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"
    ? require("../../.dfx/local/canister_ids.json").Axon.local
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "staging"
    ? CanisterIds.staging.ic
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "testic"
    ? CanisterIds.AxonTest.ic
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "voic_ic"
    ? CanisterIds.voic.ic 
    : process.env.NEXT_PUBLIC_DFX_NETWORK === "voice"
    ? require("../../../../../.dfx/local/canister_ids.json").axon.local
    : CanisterIds.Axon.ic
    
console.log(process.env.NEXT_PUBLIC_DFX_NETWORK);
console.log(`NEXT_PUBLIC_DFX_NETWORK=${process.env.NEXT_PUBLIC_DFX_NETWORK}`);
console.log(`AXON_CANISTER_ID=${AXON_CANISTER_ID}`);

const withTM = require('next-transpile-modules')(['@connect2ic/core', 'event-e3']);

module.exports = withTM({
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    // !! WARN !!
    ignoreBuildErrors: true,
  },
  env: {
    AXON_CANISTER_ID,
    LOGO_ICON: "logo2.png",
    GLOBAL_STYLES: "globals.css",
    PAGE_TITLE: "VoIC",
  },
  async rewrites() {
    return [
      {
        source: '/:path*',
        destination: '/',
      },
    ];
  },
});
