import { useQuery } from "react-query";
import { useAxon } from "../../../components/Store/Store";
import { FIVE_MINUTES_MS } from "../../constants";

export const useNeuronIds = () => {
  const axon = useAxon();
  return useQuery(
    "neuronIds",
    async () => {
      const ids = await axon.getNeuronIds();
      return ids.sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
    },
    {
      keepPreviousData: true,
      placeholderData: [],
      refetchInterval: FIVE_MINUTES_MS,
    }
  );
};
