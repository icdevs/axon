import "balloon-css";
import { createBrowserRouter } from "react-router-dom";
import { Outlet } from "react-router-dom";
import Head from "next/head";
import React from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import Footer from "../components/Layout/Footer";
import Nav from "../components/Layout/Nav";

import dynamic from "next/dynamic";
const AppWrapper = dynamic(() => import("./AppWrapper"), {
  ssr: false,
});

export default function Index() {
  return <AppWrapper />;
}
