import { useParams } from "react-router-dom";
import React from "react";
import { ProposalDetails } from "../../../../components/Proposal/ProposalDetails";

export default function ProposalPage() {
  const { proposalId } = useParams();

  return <ProposalDetails proposalId={proposalId} />;
}
