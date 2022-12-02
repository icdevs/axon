import "balloon-css";
import Head from "next/head";
import "react";
import React from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import Footer from "../components/Layout/Footer";
import Nav from "../components/Layout/Nav";
import { Subscriptions } from "../components/Query/Subscriptions";
import Store from "../components/Store/Store";
import { ONE_HOUR_MS } from "../lib/constants";
import "../styles/globals.css";

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

export default function App({ Component, pageProps }) {
  return (
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

              <Component {...pageProps} />
            </main>

            <Footer />
          </div>
        </div>
      </Store>

      {/* <ReactQueryDevtools initialIsOpen={false} /> */}
    </QueryClientProvider>
  );
}
