import { Principal } from "@dfinity/principal";
import React, { useEffect, useRef, useState } from "react";
import { Actor, HttpAgent, ActorSubclass } from '@dfinity/agent';
import { IDL, InputBox } from "@dfinity/candid";
import { renderInput } from "../../lib/candid-ui";
import { fetchActor, render, getCycles, getNames } from '../../lib/candid';
import {
  CanisterCommandRequest,
  ProposalType,
} from "../../declarations/Axon/Axon.did";
import { useAxonById } from "../../lib/hooks/Axon/useAxonById";
import ErrorAlert from "../Labels/ErrorAlert";
import { Nat8 } from "@dfinity/candid/lib/cjs/idl";
import DissolveDelayInput from "../Inputs/DissolveDelayInput";


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
  const [argsBinary, setArgsBinary] = useState<any>();
  const [error, setError] = useState("");
  const [argInputs, setArgInputs] = useState<Array<InputBox>>([]);
  const inpotBlockRef = useRef(null);

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

  const handleArgsUpdate = () => {
    const args = argInputs.map(arg => arg.parse());
    const isReject = argInputs.some(arg => arg.isRejected());
    if (isReject) {
      setError("Fill all the functions arguments");
      return;
    }
  
    const argsBinary = IDL.encode(
      service?._fields?.find((s) => s[0] === callFunction)[1]?.argTypes, args
    )

    setArgsBinary(argsBinary);
  }

  useEffect(() => {
    if (canisterId && callFunction) {
      
      try {
          const args = argInputs.map(arg => arg.parse());
          const isReject = argInputs.some(arg => arg.isRejected());
          if (isReject) {
            console.log(isReject);
            setError("Fill all the functions arguments");
            return;
          }
        
          const argsBinary = IDL.encode(
            service?._fields?.find((s) => s[0] === callFunction)[1]?.argTypes, args)

            console.log(args);
          setCommand({
            canister: Principal.fromText(canisterId),
            functionName: callFunction,
            //@ts-ignore
            argumentBinary: Array.from(argsBinary),
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
  }, [canisterId, callFunction, argsBinary]);

  useEffect(() => {
    if (callFunction) {
      const inputs: InputBox[] = [];
      service?._fields?.find((s) => s[0] === callFunction)[1]?.argTypes.forEach((arg, i) => {
        console.log(arg, i, service?._fields?.find((s) => s[0] === callFunction)[1]?.argTypes);
        console.log(arg);
        const inputbox = renderInput(arg);
        inputs.push(inputbox);
        inpotBlockRef.current.innerHTML = "";
        const rendered = inputbox.render(inpotBlockRef.current);
      })
      console.log(inputs);
      setArgInputs(inputs);
    }
  }, [callFunction]);

  if (!data) {
    return null;
  }

  // const options =
  //   data && "Closed" in data.policy.proposers
  //     ? onlyClosedProposersCommands.concat(commands)
  //     : commands;

  return (
    <div className="flex flex-col gap-2 py-4">
      <div style={{display: "flex", alignItems: "flex-end", gap: "8px"}}>
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
        <button style={{flexShrink: 0, height: "42px"}} className="rounded-md leading-none inline-flex items-center justify-center btn-cta cursor-pointer p-2 h-42" onClick={loadDid}>Load did</button>
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
          Call properties
        <form onInput={handleArgsUpdate} ref={inpotBlockRef}>
        </form>
      </div>

      {!!error && <ErrorAlert>{error}</ErrorAlert>}
    </div>
  );
}
