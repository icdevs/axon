import { Actor, HttpAgent } from "@dfinity/agent";
import React, { useEffect } from "react";
import { canisterId as AxonCanisterId } from "../../declarations/Axon";
import { useSetAgent } from "../Store/Store";

import { ConnectButton, ConnectDialog, useConnect, useCanister } from "@connect2ic/react"
import { HOST } from "../../lib/canisters";

export const Connect2ICButton: React.FC = (props) => {
  const setAgent = useSetAgent();
  const { isConnected, activeProvider } = useConnect({
    onConnect: () => {
			const [actor, err] = useCanister(AxonCanisterId)
			setAgent({
        agent: new HttpAgent({
					//@ts-ignore
					identity: activeProvider.identity,
					host: HOST,
				}),
        isAuthed: true,
      });
      // setAgent({
      //   agent: Actor.agentOf(actor) as undefined as HttpAgent,
      //   isAuthed: true,
      // });
    },
    onDisconnect: () => {
      setAgent({
        agent: null,
        isAuthed: false,
      });
    }
  })

  useEffect(() => {
		if (isConnected) {
			console.log("CONNECTED:", { isConnected, activeProvider })
      setAgent({
        agent: new HttpAgent({
					//@ts-ignore
					identity: activeProvider.identity,
					host: HOST,
				}),
        isAuthed: true,
      });
		} else {
			setAgent({
        agent: null,
        isAuthed: false,
      });
		}
  }, [isConnected]);

  return (
		global.window ? <>
			<ConnectButton />
			<ConnectDialog />
		</>
		: null
  )
}
