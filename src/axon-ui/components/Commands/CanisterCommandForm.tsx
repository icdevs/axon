import { Principal } from "@dfinity/principal";
import React, { useEffect, useState } from "react";
import {
  CanisterCommandRequest,
  ProposalType,
} from "../../declarations/Axon/Axon.did";
import { useAxonById } from "../../lib/hooks/Axon/useAxonById";
import ErrorAlert from "../Labels/ErrorAlert";

export default function CanisterCommandForm({
  setProposal,
}: {
  setProposal: (at: ProposalType) => void;
}) {
  const { data } = useAxonById();
  const [canisterId, setCanisterId] = useState("");
  const [callFunction, setCallFunction] = useState("");
  const [callProperies, setCallProperies] = useState("");
  const [error, setError] = useState("");

  function setCommand(command: CanisterCommandRequest) {
    if (!command) {
      setProposal(null);
    } else {
      setProposal({
        CanisterCommand: [command, []],
      });
    }
  }

  useEffect(() => {
    // TODO: find possible refactoring got binary aarray )
    function text2Binary(string) {
      return string.split('').map(function (char) {
          return char.charCodeAt(0).toString(2);
      }).join('').split('').map((bit) => parseInt(bit, 2));
    }
    if (canisterId && callFunction && callProperies) {
      try {
        setCommand({
          canister: Principal.fromText(canisterId),
          functionName: callFunction,
          argumentBinary: text2Binary(callProperies),
        })
        setError('');
      } catch(err) {
        console.log(err.message);
        setCommand(null);
        setError(err.message);
      }
    } else {
      setCommand(null);
    }
  }, [canisterId, callFunction, callProperies]);

  if (!data) {
    return null;
  }

  // const options =
  //   data && "Closed" in data.policy.proposers
  //     ? onlyClosedProposersCommands.concat(commands)
  //     : commands;

  return (
    <div className="flex flex-col gap-2 py-4">
      <div>
        <label className="block">
          Canister Id
          <input
            type="text"
            placeholder="Canister Id"
            className="w-full mt-1"
            value={canisterId}
            onChange={(e) => setCanisterId(e.target.value)}
            min={0}
            required
          />
        </label>
      </div>
      <div>
        <label className="block">
          Call function name
          <input
            type="text"
            placeholder="Title"
            className="w-full mt-1"
            value={callFunction}
            onChange={(e) => setCallFunction(e.target.value)}
            min={0}
            required
          />
        </label>
      </div>
      <div>
        <label className="block">
          Call properties
          <input
            type="text"
            placeholder="Title"
            className="w-full mt-1"
            value={callProperies}
            onChange={(e) => setCallProperies(e.target.value)}
            min={0}
            required
          />
        </label>
      </div>

      {!!error && <ErrorAlert>{error}</ErrorAlert>}
    </div>
  );
}
