import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";
import React, { useEffect, useState } from "react";
import {
  CanisterCommandResponse,
  CanisterCommandRequest,
} from "../../declarations/Axon/Axon.did";
import { fetchActor } from "../../lib/candid";
import { toJson } from "../../lib/utils";
import {
  CommandSuccess,
} from "../Proposal/CommandResponseSummary";

export const CanisterCommandResponseSummary = ({
  response,
  request,
}: {
  response: CanisterCommandResponse;
  request: CanisterCommandRequest;
}) => {
  
  const [service, setService] = useState<any>();
  const [respArgs, setRespArgs] = useState("");

  const loadDid = async () => {
    const DidActor = await fetchActor(Principal.fromText(request.canister.toString()));
    setService(DidActor.idl({ IDL }));
  }

  useEffect(() => {
    if (service) {
      try {
        const args = service?._fields?.find((s) => s[0] === request.functionName)[1]?.retTypes;
        const b = Buffer.from(response.reply);
        const argsDecoded = IDL.decode(args, b);
        
        setRespArgs(toJson(argsDecoded));
      } catch (e) {
        console.log(e);
      }
    }
  }, [service]);

  useEffect(() => {
    loadDid()
  }, []);

  return (
    <CommandSuccess label="Success">
      {respArgs || response.reply.toString()}
    </CommandSuccess>
  )
};
