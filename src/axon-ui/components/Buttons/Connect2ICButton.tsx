import React from "react";
import { ConnectButton, ConnectDialog } from "@connect2ic/react";
import { FaWallet } from "react-icons/fa";

export const Connect2ICButton: React.FC = (props) => {
  return global.window ? (
    <>
      <ConnectButton>
        <FaWallet style={{ marginRight: "0.5rem" }} /> Connect Wallet
      </ConnectButton>
      <ConnectDialog />
    </>
  ) : null;
};
