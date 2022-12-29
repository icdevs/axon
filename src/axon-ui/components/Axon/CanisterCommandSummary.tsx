import React from "react";
import { CanisterCommand } from "../../declarations/Axon/Axon.did";
import { DataRow, DataTable } from "../Proposal/DataTable";

export default function CanisterCommandSummary({
  canisterCommand: [request, response],
}: {
  canisterCommand: CanisterCommand;
}) {
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
            {}
          </DataRow>
        </DataTable>
    </div>
  )
}
