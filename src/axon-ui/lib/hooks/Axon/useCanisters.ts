import { useQuery } from "react-query";
import { useAxon } from "../../../components/Store/Store";
import { FIVE_MINUTES_MS } from "../../constants";
import { errorToString, tryCall } from "../../utils";
import useAxonId from "../useAxonId";

export const useCanisters = () => {
  const id = useAxonId();

  return useQuery(
    ["canisters", id],
    () => {
      try {
        return JSON.parse(localStorage.getItem('canisters'));
      } catch (err) {
        throw errorToString(err);
      }
    },
    {
      enabled: !!id,
      keepPreviousData: true,
      refetchInterval: FIVE_MINUTES_MS,
    }
  );
};
