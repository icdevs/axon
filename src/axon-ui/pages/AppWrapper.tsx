import { Outlet, RouterProvider, createBrowserRouter } from "react-router-dom";
import { createClient } from "@connect2ic/core";
import { Connect2ICProvider } from "@connect2ic/react";
import { defaultProviders } from "@connect2ic/core/providers";
import "@connect2ic/core/style.css";
import * as governanceCanister from "../declarations/Governance";
import * as axonCanister from "../declarations/Axon";
import Store from "../components/Store/Store";
import { CANISTER_NAME } from "../lib/canisters";
import { QueryClient, QueryClientProvider } from "react-query";
import { Subscriptions } from "../components/Query/Subscriptions";
import { ONE_HOUR_MS } from "../lib/constants";
import Home from "./Home";
import CreateAxonPage from "./axon/new";
import AxonPage from "./axon/[id]";
import LedgerPage from "./axon/[id]/ledger";
import ProposalPage from "./axon/[id]/proposal/[proposalId]";
import NeuronPage from "./axon/[id]/neuron/[neuronId]";
import Neurons from "../components/Neuron/Neurons";
import Head from "next/head";
import Nav from "../components/Layout/Nav";
import Footer from "../components/Layout/Footer";

const Root: React.FC = () => {
  console.log("Rendering Root");
  return (
    <div>
      <Head>
        <title>{process.env.PAGE_TITLE}</title>
      </Head>
      <div
        className="flex flex-col items-center"
        style={{ backgroundColor: "#F7F3E9" }}
      >
        <div className="flex flex-col justify-between min-h-screen w-full sm:max-w-screen-lg px-4">
          <main className="flex flex-col justify-start">
            <Nav />
            <Outlet />
          </main>
          <Footer />
        </div>
      </div>
    </div>
  );
};
export default () => {
  const client = createClient({
    canisters: {
      [CANISTER_NAME.GOVERNANCE_CANISTER]: governanceCanister,
      [CANISTER_NAME.AXON_CANISTER]: axonCanister,
    },
    providers: defaultProviders,
    globalProviderConfig: {
      host: "https://boundary.ic0.app",
      dev: false,
      whitelist: [governanceCanister.canisterId, axonCanister.canisterId],
    },
  });

  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        refetchOnWindowFocus: false,
        staleTime: Infinity,
        cacheTime: ONE_HOUR_MS,
        retry: false,
      },
    },
  });

  const router = createBrowserRouter([
    {
      path: "/",
      element: <Root />,
      children: [
        {
          path: "/",
          element: <Home />,
        },
        {
          path: "/axon/new",
          element: <CreateAxonPage />,
        },
        {
          path: "/axon/:id",
          element: <AxonPage />,
        },
        {
          path: "/axon/:id/ledger",
          element: <LedgerPage />,
        },
        {
          path: "/axon/:id/proposal/:proposalId",
          element: <ProposalPage />,
        },
        {
          path: "/axon/:id/neurons",
          element: <Neurons />,
        },
        {
          path: "/axon/:id/neurons/:neuronId",
          element: <NeuronPage />,
        },
      ],
    },
  ]);

  if (!client) {
    return <></>;
  }

  return (
    <Connect2ICProvider client={client}>
      <QueryClientProvider client={queryClient}>
        <Store>
          <Subscriptions />
          <RouterProvider router={router} />
        </Store>
      </QueryClientProvider>
    </Connect2ICProvider>
  );
};
