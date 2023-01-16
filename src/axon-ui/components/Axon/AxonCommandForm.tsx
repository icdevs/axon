import React, { useState } from "react";
import {
  AxonCommandRequest,
  ProposalType,
} from "../../declarations/Axon/Axon.did";
import { useAxonById } from "../../lib/hooks/Axon/useAxonById";
import { KeysOfUnion } from "../../lib/types";
import { AddProposersForm } from "./AddProposersForm";
import { AddMintersForm } from "./AddMintersForm";
import { BurnForm } from "./BurnForm";
import { MintForm } from "./MintForm";
import { MotionForm } from "./MotionForm";
import { PolicyFormWithDefaults } from "./PolicyForm";
import { RedenominateForm } from "./RedenominateForm";
import { RemoveProposersForm } from "./RemoveProposersForm";
import { RemoveMintersForm } from "./RemoveMintersForm";
import { TransferForm } from "./TransferForm";
import { VisibilityForm } from "./VisibilityForm";

const onlyClosedProposersCommands: [AxonCommandName, string][] = [
  ["AddMembers", "Add Proposers"],
  ["RemoveMembers", "Remove Proposers"],
];

const commands: [AxonCommandName, string][] = [
  ["SetVisibility", "Set Visibility"],
  ["SetPolicy", "Set Policy"],
  ["Mint", "Mint"],
  ["Burn", "Burn"],
  ["Transfer", "Transfer"],
  ["AddMinters", "Add Minters"],
  ["RemoveMinters", "Remove Minters"],
  ["Redenominate", "Redenominate"],
  ["Motion", "Motion Proposal"],
];

type AxonCommandName = KeysOfUnion<AxonCommandRequest>;

export default function AxonCommandForm({
  setProposal,
  defaultCommand,
}: {
  setProposal: (at: ProposalType) => void;
  defaultCommand?: AxonCommandRequest;
}) {
  const { data } = useAxonById();
  const [commandName, setCommandName] = useState<AxonCommandName>(
    defaultCommand
      ? (Object.keys(defaultCommand)[0] as AxonCommandName)
      : commands[0][0]
  );

  function setCommand(command: AxonCommandRequest) {
    if (!command) {
      setProposal(null);
    } else {
      setProposal({
        AxonCommand: [command, []],
      });
    }
  }

  const renderForm = () => {
    switch (commandName) {
      case "AddMembers":
        return (
          <AddProposersForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "AddMembers" in defaultCommand
                ? defaultCommand.AddMembers
                : undefined
            }
          />
        );
      case "RemoveMembers":
        return (
          <RemoveProposersForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "RemoveMembers" in defaultCommand
                ? defaultCommand.RemoveMembers
                : undefined
            }
          />
        );

        case "AddMinters":
          return (
            <AddMintersForm
              makeCommand={setCommand}
              defaults={
                defaultCommand && "AddMinters" in defaultCommand
                  ? defaultCommand.AddMinters
                  : undefined
              }
            />
          );
        case "RemoveMinters":
          return (
            <RemoveMintersForm
              makeCommand={setCommand}
              defaults={
                defaultCommand && "RemoveMinters" in defaultCommand
                  ? defaultCommand.RemoveMinters
                  : undefined
              }
            />
          );
      case "SetVisibility":
        return (
          <VisibilityForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "SetVisibility" in defaultCommand
                ? defaultCommand.SetVisibility
                : undefined
            }
          />
        );
      case "SetPolicy":
        return (
          <PolicyFormWithDefaults
            makeCommand={setCommand}
            defaults={
              defaultCommand && "SetPolicy" in defaultCommand
                ? defaultCommand.SetPolicy
                : undefined
            }
          />
        );
      case "Mint":
        return (
          <MintForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "Mint" in defaultCommand
                ? defaultCommand.Mint
                : undefined
            }
          />
        );
      case "Burn":
        return (
          <BurnForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "Burn" in defaultCommand
                ? defaultCommand.Burn
                : undefined
            }
          />
        );
      case "Transfer":
        return (
          <TransferForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "Transfer" in defaultCommand
                ? defaultCommand.Transfer
                : undefined
            }
          />
        );
      case "Redenominate":
        return (
          <RedenominateForm
            makeCommand={setCommand}
            defaults={
              defaultCommand && "Redenominate" in defaultCommand
                ? defaultCommand.Redenominate
                : undefined
            }
          />
        );
      case "Motion":
        return (
          <MotionForm
            makeCommand={setCommand}
          />
        );
    }
    return null;
  };

  if (!data) {
    return null;
  }

  const options =
    data && "Closed" in data.policy.proposers
      ? onlyClosedProposersCommands.concat(commands)
      : commands;

  return (
    <div className="flex flex-col gap-2 py-4">
      <div>
        <label>Command</label>
        <select
          className="w-full mt-1"
          onChange={(e) => setCommandName(e.target.value as AxonCommandName)}
          value={commandName}
        >
          {options.map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
      </div>

      {renderForm()}
    </div>
  );
}
