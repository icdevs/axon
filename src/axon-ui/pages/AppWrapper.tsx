import { RouterProvider } from "react-router-dom";
import { createClient } from "@connect2ic/core";
import { Connect2ICProvider } from "@connect2ic/react";
import { defaultProviders } from "@connect2ic/core/providers";
import "@connect2ic/core/style.css";
import * as governanceCanister from "../declarations/Governance";
import * as axonCanister from "../declarations/Axon";
import Store from "../components/Store/Store";
import { CANISTER_NAME } from "../lib/canisters";

export default ({ router }) => {
  const client = createClient({
    canisters: {
      [CANISTER_NAME.GOVERNANCE_CANISTER]: governanceCanister,
      [CANISTER_NAME.AXON_CANISTER]: axonCanister,
    },
    providers: defaultProviders,
    globalProviderConfig: {
      host: "https://icp-api.io",
      dev: false,
    },
  });

  if (!client) {
    return <RouterProvider router={router} />;
  }
  return (
    <Connect2ICProvider client={client}>
      <Store>
        <RouterProvider router={router} />
      </Store>
    </Connect2ICProvider>
  );
};
