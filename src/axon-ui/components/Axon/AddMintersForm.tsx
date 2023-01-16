import { Principal } from "@dfinity/principal";
import React, { useEffect, useState } from "react";
import CreatableSelect from "react-select/creatable";
import { AxonCommandRequest } from "../../declarations/Axon/Axon.did";
import { useAxonById } from "../../lib/hooks/Axon/useAxonById";
import { formatNumber } from "../../lib/utils";
import ErrorAlert from "../Labels/ErrorAlert";

export function AddMintersForm({
  makeCommand,
  defaults,
}: {
  makeCommand: (cmd: AxonCommandRequest | null) => void;
  defaults?: Extract<AxonCommandRequest, { AddMinters: {} }>["AddMinters"];
}) {
  const { data } = useAxonById();
  const [users, setUsers] = useState(defaults?.map((p) => p.toText()) ?? []);
  const [inputError, setInputError] = useState("");

  useEffect(() => {
    setInputError("");
    if (!users.length) {
      return makeCommand(null);
    }

    let AddMinters: Principal[];
    try {
      AddMinters = users.map((value) => Principal.fromText(value));
    } catch (err) {
      setInputError(`Invalid principal: ${err.message}`);
      return makeCommand(null);
    }

    makeCommand({
      AddMinters,
    });
  }, [users]);

  return (
    <div className="flex flex-col gap-2">
      <p className="text-sm leading-tight">
        Specify the Principals that are able to mint and burn tokens.
      </p>

      <label className="block">
        <span>Minters</span>
        <CreatableSelect
          className="react-select"
          isMulti={true}
          onChange={(values) => setUsers(values.map(({ value }) => value))}
          defaultValue={defaults?.map((p) => ({
            value: p.toText(),
            label: p.toText(),
          }))}
        />
      </label>

      {!!inputError && <ErrorAlert>{inputError}</ErrorAlert>}
    </div>
  );
}
