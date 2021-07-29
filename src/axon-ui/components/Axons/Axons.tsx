import Link from "next/link";
import React from "react";
import { BiListUl } from "react-icons/bi";
import { useCount } from "../../lib/hooks/Axons/useCount";
import { RefreshButton } from "../Buttons/RefreshButton";
import Panel from "../Containers/Panel";
import ResponseError from "../Labels/ResponseError";

export default function Axons() {
  const { data, isSuccess, isFetching, refetch, error } = useCount();

  return (
    <Panel>
      <div className="flex gap-2 items-center mb-2">
        <h2 className="text-xl font-bold">All Axons</h2>
        <RefreshButton
          isFetching={isFetching}
          onClick={refetch}
          title="Refresh count"
        />
      </div>
      <div>
        {error && <ResponseError>{error}</ResponseError>}
        {data ? (
          <div className="grid md:grid-cols-3 grid-cols-1 gap-8 p-4">
            {Array.from({ length: data }).map((_, id) => (
              <Link key={id.toString()} href={`/axon/${id}`}>
                <a className="flex items-center justify-center bg-gradient-to-br from-green-300 via-blue-500 to-purple-600 rounded-xl text-xl text-white h-48 hover:shadow-xl transition">
                  Axon {id}
                </a>
              </Link>
            ))}
          </div>
        ) : (
          isSuccess && (
            <div className="h-40 flex flex-col items-center justify-center">
              <BiListUl size={48} className="" />
              <p className="py-2">No Axons</p>
            </div>
          )
        )}
      </div>
    </Panel>
  );
}
