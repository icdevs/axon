import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";
import React, { useEffect, useState } from "react";
import { CanisterCommand } from "../../declarations/Axon/Axon.did";
import { fetchActor } from "../../lib/candid";
import { toJson } from "../../lib/utils";
import { DataRow, DataTable } from "../Proposal/DataTable";

export default function CanisterCommandSummary({
  canisterCommand: [request, response],
}: {
  canisterCommand: CanisterCommand;
}) {
  const [service, setService] = useState<any>();
  const [reqArgs, setReqArgs] = useState("");

  const loadDid = async () => {
    const DidActor = await fetchActor(Principal.fromText(request.canister.toString()));
    setService(DidActor.idl({ IDL }));
  }

  useEffect(() => {
    if (request && service) {
      try {
        const args = service?._fields?.find((s) => s[0] === request.functionName)[1]?.argTypes;
        const b = Buffer.from(request.argumentBinary);
        const argsDecoded = IDL.decode(args, b);
        setReqArgs(toJson(argsDecoded));
      } catch (e) {
        console.log(e);
      }
    }
  }, [request, service]);

  useEffect(() => {
    loadDid()
  }, []);

  console.log(response, request);

  return (
    <div>
      <DataTable label={`Execute function on canister`}>
          <DataRow labelClassName="w-40" label="Canister">
            {request.canister.toString()}
          </DataRow>
          <DataRow labelClassName="w-40" label="Function">
            {request.functionName}
          </DataRow>
          <DataRow labelClassName="w-40" label="Canister">
            {reqArgs || request.argumentBinary.toString()}
          </DataRow>
        </DataTable>
    </div>
  )
}
