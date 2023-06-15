import { AppProps } from "next/app";
import { SafeHydrate } from "../components/SafeHydrate/SafeHydrate";
import("../styles/" + process.env.GLOBAL_STYLES);

function App({ Component, pageProps }: AppProps) {
  return (
    <SafeHydrate>
      <Component {...pageProps} />
    </SafeHydrate>
  );
}
export default App;
