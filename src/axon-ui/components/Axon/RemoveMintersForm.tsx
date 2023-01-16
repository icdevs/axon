import { Principal } from "@dfinity/principal";
import React, { useEffect, useState } from "react";
import Select from "react-select";
import { AxonCommandRequest } from "../../declarations/Axon/Axon.did";
import { useAxonById } from "../../lib/hooks/Axon/useAxonById";
import useNames from "../../lib/hooks/useNames";

export function RemoveMintersForm({
  makeCommand,
  defaults,
}: {
  makeCommand: (cmd: AxonCommandRequest | null) => void;
  defaults?: Extract<
    AxonCommandRequest,
    { RemoveMinters: {} }
  >["RemoveMinters"];
}) {
  const { principalName } = useNames();
  const { data } = useAxonById();
  const [users, setUsers] = useState(defaults?.map((p) => p.toText()) ?? []);
  const [inputError, setInputError] = useState("");

  const Minters =
    data && "Minters" in data.policy.minters
      ? data.policy.minters.Minters
      : [];
  const MintersOptions = Minters.map((principal) => {
    const value = principal.toText();
    return { value, label: principalName(value) };
  });

  useEffect(() => {
    setInputError("");
    if (!users.length || Minters.length <= 1) {
      return makeCommand(null);
    }

    let RemoveMinters: Principal[];
    try {
      RemoveMinters = users.map((value) => Principal.fromText(value));
    } catch (err) {
      setInputError(`Invalid principal: ${err.message}`);
      return makeCommand(null);
    }

    makeCommand({
      RemoveMinters,
    });
  }, [users]);

  return (
    <div className="flex flex-col gap-2">
      <p className="text-sm leading-tight">
        Remove Principals from the set of eligible Minters.
      </p>

      
      <label className="block">
        <span>Minters</span>
        <Select
          className="react-select"
          isMulti={true}
          onChange={(values) => setUsers(values.map(({ value }) => value))}
          options={MintersOptions}
          defaultValue={defaults?.map((p) => ({
            value: p.toText(),
            label: p.toText(),
          }))}
        />
      </label>
     
    </div>
  );
}
