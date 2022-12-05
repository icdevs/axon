import { Link } from "react-router-dom";
import React from "react";
import { IdentifierRenderProps } from "../Buttons/IdentifierLabelWithButtons";

export const renderNeuronIdLink = (axonId: string) => {
  return ({ rawId, displayId, name }: IdentifierRenderProps) => {
    const display = name ?? displayId;
    return (
      <Link to={`/axon/${axonId}/neuron/${rawId}`} className="text-blue-600 font-semibold hover:underline cursor-pointer">
        {display}
      </Link>
    );
  };
};
