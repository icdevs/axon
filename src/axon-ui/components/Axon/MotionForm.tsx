import React, { useEffect, useState } from "react";
import { AxonCommandRequest } from "../../declarations/Axon/Axon.did";
import ErrorAlert from "../Labels/ErrorAlert";

export function MotionForm({
  makeCommand,
}: {
  makeCommand: (cmd: AxonCommandRequest | null) => void;
  defaults?: Extract<AxonCommandRequest, { Motion: {} }>["Motion"];
}) {
  const [body, setBody] = useState("");
  const [title, setTitle] = useState("");
  const [url, setUrl] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let command: AxonCommandRequest;
    
    command = {
      Motion: {
        url,
        title,
        body
      },
    };
    makeCommand(command);
  }, [url, title, body]);

  return (
    <div className="flex flex-col gap-2">
      <p className="text-sm leading-tight">
        Create Motion Proposal.
      </p>

      <label className="block">
        Title
        <input
          type="text"
          placeholder="Title"
          className="w-full mt-1"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          min={0}
          required
        />
      </label>

      <label className="block">
        URL
        <input
          type="text"
          placeholder="URL"
          className="w-full mt-1"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          required
        />
      </label>

      <label className="block">
        Body
        <input
          type="text"
          placeholder="Motion description"
          className="w-full mt-1"
          value={body}
          onChange={(e) => setBody(e.target.value)}
          required
        />
      </label>

      {!!error && <ErrorAlert>{error}</ErrorAlert>}
    </div>
  );
}
