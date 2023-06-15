import { Actor, Agent, HttpAgent } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import React, { createContext, useContext, useEffect, useReducer } from "react";
import { CANISTER_NAME, defaultAgent } from "../../lib/canisters";
import { AxonService } from "../../lib/types";
import { useCanister, useConnect } from "@connect2ic/react";

type Action =
  | {
      type: "LOAD_PERSISTENT_STATE";
      value: State["persistent"];
    }
  | {
      type: "SET_HIDE_ZERO_BALANCES";
      value: boolean;
    };

const reducer = (state: State, action: Action) => {
  switch (action.type) {
    case "LOAD_PERSISTENT_STATE":
      return {
        ...state,
        persistent: action.value,
      };
    case "SET_HIDE_ZERO_BALANCES":
      return {
        ...state,
        persistent: {
          ...state.persistent,
          hideZeroBalances: action.value,
        },
      };
  }
};

type State = {
  agent: Agent;
  axon: AxonService;
  isAuthed: boolean;
  principal: Principal | null;
  persistent: {
    hideZeroBalances: boolean;
  };
};

const initialState: State = {
  agent: defaultAgent,
  axon: undefined,
  isAuthed: false,
  principal: null,
  persistent: {
    hideZeroBalances: true,
  },
};

const Context = createContext({
  state: initialState,
  dispatch: (_: Action) => null,
});

const Store = ({ children }) => {
  const [state, dispatch] = useReducer(reducer, initialState);

  // const { principal, isConnected } = useConnect();
  // const [actor, res] = useCanister("gov");

  // const connect2IcState = {
  //   axon: actor as unknown as AxonService,
  //   agent: Actor.agentOf(actor),
  //   principal: Principal.fromText(principal),
  //   isAuthed: isConnected,
  // };

  useEffect(() => {
    try {
      const stored = localStorage.getItem("state");
      if (stored) {
        const value = JSON.parse(stored);
        dispatch({ type: "LOAD_PERSISTENT_STATE", value });
      }
    } catch (error) {
      console.log(error);
    }
  }, []);

  useEffect(() => {
    if (typeof window !== "undefined") {
      window.localStorage.setItem("state", JSON.stringify(state.persistent));
    }
  }, [state.persistent]);

  const aggregatedState = {
    ...state,
  };

  return (
    <Context.Provider value={{ state: aggregatedState, dispatch }}>
      {children}
    </Context.Provider>
  );
};

export const useGlobalContext = () => {
  const context = useContext(Context);
  if (context === undefined) {
    throw new Error("useGlobalContext must be used within a CountProvider");
  }
  return context;
};

export const useAxon = () => {
  const [actor] = useCanister(CANISTER_NAME.AXON_CANISTER);
  return actor;
};

export const useHideZeroBalances = () => {
  const context = useGlobalContext();

  const state = context.state.persistent.hideZeroBalances;
  const dispatch = (value: boolean) =>
    context.dispatch({ type: "SET_HIDE_ZERO_BALANCES", value });

  return [state, dispatch] as const;
};

export default Store;
