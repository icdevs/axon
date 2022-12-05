import { useParams } from "react-router";

export default function useAxonId(): string | undefined {
  const { id } = useParams();
  return id;
}
