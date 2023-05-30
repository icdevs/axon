import { RouterProvider } from "react-router-dom";
import { createClient } from "@connect2ic/core";
import { Connect2ICProvider } from "@connect2ic/react";
import { defaultProviders } from "@connect2ic/core/providers";
import "@connect2ic/core/style.css";
import * as governanceCanister from "../declarations/Governance";

export default ({ router }) => {
  const client = createClient({
    canisters: {
      governanceCanister,
    },
    providers: defaultProviders,
    globalProviderConfig: {
      host: "https://boundary.ic0.app",
      dev: false,
    },
  });

  if (!client) {
    return <RouterProvider router={router} />;
  }
  return (
    <Connect2ICProvider client={client}>
      <RouterProvider router={router} />
    </Connect2ICProvider>
  );
};
