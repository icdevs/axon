import { useQuery } from "react-query";
import { useAxon } from "../../components/Store/Store";
import { tryCall } from "../utils";

export const useIsAdmin = () => {
  const axon = useAxon();
  console.log("Checked if Admin");
  return useQuery(
    "isAdmin",
    async () => {
      return await tryCall(axon.is_admin);
    },
    {
      staleTime: Infinity,
    }
  );
};