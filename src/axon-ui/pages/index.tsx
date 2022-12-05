import "balloon-css";
import {
  createBrowserRouter,
  RouterProvider,
  Route,
} from "react-router-dom";
import { Outlet } from "react-router-dom";
import Head from "next/head";
import "react";
import React, { PropsWithChildren } from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import Footer from "../components/Layout/Footer";
import Nav from "../components/Layout/Nav";
import { Subscriptions } from "../components/Query/Subscriptions";
import Store from "../components/Store/Store";
import { ONE_HOUR_MS } from "../lib/constants";
import Home from "./Home";
import CreateAxonPage from "./axon/new";
import AxonPage from "./axon/[id]";
import LedgerPage from "./axon/[id]/ledger";
import ProposalPage from "./axon/[id]/proposal/[proposalId]";
import NeuronPage from "./axon/[id]/neuron/[neuronId]";
import Neurons from "../components/Neuron/Neurons";

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

const Root: React.FC = () => {
  return (
    <div>
      <QueryClientProvider client={queryClient}>
        <Store>
          <Subscriptions />
          <Head>
            <title>ICDEV Governance Tool</title>
          </Head>
          <div className="flex flex-col items-center" style={{backgroundColor: "#F7F3E9"}}>
            <div className="flex flex-col justify-between min-h-screen w-full sm:max-w-screen-lg px-4">
              <main className="flex flex-col justify-start">
                <Nav />
                <Outlet />  
              </main>
              <Footer />
            </div>
          </div>
        </Store>

        {/* <ReactQueryDevtools initialIsOpen={false} /> */}
      </QueryClientProvider>
    </div>
  )
}

export default function Index() {
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
      ]
    },
  ]);

  return (
    <div suppressHydrationWarning>
      <RouterProvider router={router}/>
    </div>
  );
}
