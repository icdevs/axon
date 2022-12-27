import { Principal } from "@dfinity/principal";
import React, { useEffect, useState } from "react";
import { Actor, HttpAgent, ActorSubclass } from '@dfinity/agent';
import { IDL } from "@dfinity/candid";
import { fetchActor, render, getCycles, getNames } from '../../lib/candid';
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
  const [functionsOptions, setFunctionsOptions] = useState([]);
  const [service, setService] = useState<any>();
  const [error, setError] = useState("");

  const handleFileSelect = (e) => {
    const did = e.target;
    const reader = new FileReader();
    reader.addEventListener("load", async () => {
      const encoded = reader.result as string;
      const hex = encoded.substr(encoded.indexOf(',') + 1);
      const DidActor = await fetchActor(Principal.fromText(canisterId), hex);
      console.log(DidActor)
      setFunctionsOptions(Object.keys(DidActor.actor));
      setService(DidActor.idl({ IDL }));
    });
    reader.readAsDataURL(did.files![0]);
  };

  const loadDid = async () => {
    const DidActor = await fetchActor(Principal.fromText(canisterId));
    setFunctionsOptions(Object.keys(DidActor.actor));
    setService(DidActor.idl({ IDL }));
  }

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
    if (canisterId && callFunction && callProperies) {
      try {
        const args = IDL.encode(
          service?._fields?.find((s) => s[0] === callFunction)[1]?.argTypes,
           callProperies ? JSON.parse(callProperies) : ""
           )
        console.log(args);
        setCommand({
          canister: Principal.fromText(canisterId),
          functionName: callFunction,
          argumentBinary: args,
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
        <button onClick={loadDid}>Load did from cansiter</button>
      </div>
      <div>
        <label className="block">
          Canister .did file
          <input
            type="file"
            className="w-full mt-1"
            onChange={(e) => handleFileSelect(e)}
          />
        </label>
      </div>
      <div>
        <label className="block">
          Select function to call
          <select
            className="w-full mt-1"
            value={callFunction}
            onChange={(e) => setCallFunction(e.target.value)}
            required
            >
            {
              functionsOptions.map((opt) => <option>{opt}</option>)
            }
          </select>
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
          />
        </label>
      </div>

      {!!error && <ErrorAlert>{error}</ErrorAlert>}
    </div>
  );
}
