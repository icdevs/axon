import React from "react";
import { ConnectButton, ConnectDialog, useConnect } from "@connect2ic/react";
import { FaWallet, FaPlug } from "react-icons/fa";

export const Connect2ICButton: React.FC = (props) => {
  const { principal, isConnected } = useConnect();
  const principalAsText = principal?.substring(0, 25) + "..";
  return global.window ? (
    <>
      <ConnectButton>
        {isConnected && principal ? (
          <>
            <FaPlug style={{ marginRight: "0.5rem" }} />
            {principalAsText}
          </>
        ) : (
          <>
            <FaWallet style={{ marginRight: "0.5rem" }} /> Connect Wallet
          </>
        )}
      </ConnectButton>
      <ConnectDialog />
    </>
  ) : null;
};
