import { useCanisters } from "./useCanisters";

export const useCanisterIds = () => {
  const canisters = useCanisters();
  return canisters.data?.response.full_canisters.map((n) => n.id[0]) ?? [];
};
