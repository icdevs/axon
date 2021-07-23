import classNames from "classnames";
import React from "react";
import { StatusKey } from "../../lib/types";

const colorOf = (status: StatusKey) => {
  switch (status) {
    case "Pending":
    case "Accepted":
    case "Executed":
      return "bg-green-300 text-green-700";
    case "Executing":
      return "bg-blue-200 text-blue-700";
    case "Rejected":
      return "bg-red-300 text-red-700";
    case "Expired":
      return "bg-gray-300 text-gray-700";
  }
};

export default function StatusLabel({ status }: { status: StatusKey }) {
  return (
    <label
      className={classNames(
        "block w-20 text-center py-0.5 rounded text-xs uppercase",
        colorOf(status)
      )}
    >
      {status}
    </label>
  );
}
