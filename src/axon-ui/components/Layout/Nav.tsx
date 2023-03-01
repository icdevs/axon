import { Link } from "react-router-dom";
import React from "react";
import { useBalance } from "../../lib/hooks/Axon/useBalance";
import useAxonId from "../../lib/hooks/useAxonId";
import { formatNumber } from "../../lib/utils";
import IdentifierLabelWithButtons from "../Buttons/IdentifierLabelWithButtons";
import LoginButton from "../Buttons/LoginButton";
import { useGlobalContext } from "../Store/Store";
import { Connect2ICButton } from "../Buttons/Connect2ICButton";

export default function Nav() {
  const {
    state: { principal },
  } = useGlobalContext();
  const { data: balance } = useBalance();
  const id = useAxonId();

  return (
    <nav className="py-4 flex flex-col sm:flex-row items-center justify-between border-b border-black border-opacity-10">
      <Link to="/">
        <img src={`/img/${process.env.LOGO_ICON}`} className="h-36 cursor-pointer" />
      </Link>
      <div className="flex items-center gap-4">
        {principal && !principal.isAnonymous() && (
          <div className="flex flex-col">
            <IdentifierLabelWithButtons
              type="Principal"
              id={principal}
              isShort={true}
              showName={false}
            />

            {id && (
              <Link to={`/axon/${id}/ledger`} className="text-right hover:underline">
                <>
                  <strong>{formatNumber(balance || 0)}</strong> AXON_{id}
                </>
              </Link>
            )}
          </div>
        )}
        {
          global.window && 
            <Connect2ICButton />
        }
        {/* <LoginButton /> */}
      </div>
    </nav>
  );
}
