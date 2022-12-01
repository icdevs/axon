import React from "react";
import { Motion__1 } from "../../declarations/Axon/Axon.did";
import { formatNumber, formatPercent } from "../../lib/utils";
import IdentifierLabelWithButtons from "../Buttons/IdentifierLabelWithButtons";
import { DataRow, DataTable } from "../Proposal/DataTable";

export default function MotionSummary({
  label,
  motion: { url, title, body },
}: {
  label?: string;
  motion: Motion__1;
}) {
  return (
    <DataTable label={label}>
      <DataRow labelClassName="w-40" label="Title">
        {title}
      </DataRow>
      <DataRow labelClassName="w-40" label="URL">
        {url}
      </DataRow>
      <DataRow labelClassName="w-40" label="Body">
        {body}
      </DataRow>
    </DataTable>
  );
}
