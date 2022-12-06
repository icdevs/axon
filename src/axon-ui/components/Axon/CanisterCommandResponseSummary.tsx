import React from "react";
import {
  CanisterCommandResponse,
} from "../../declarations/Axon/Axon.did";
import {
  CommandSuccess,
} from "../Proposal/CommandResponseSummary";

export const CanisterCommandResponseSummary = ({
  response,
}: {
  response: CanisterCommandResponse;
}) => {
  
  return (
    <CommandSuccess label="Success">
      {response.reply.toString()}
    </CommandSuccess>
  )
};
