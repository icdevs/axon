import { AppProps } from 'next/app';
import "../styles/globals.css";

function SafeHydrate({ children }) {
  return (
    <div suppressHydrationWarning>
      {typeof window === 'undefined' ? null : children}
    </div>
  )
}

function App({ Component, pageProps }: AppProps) {
  return (
    <SafeHydrate><Component {...pageProps} /></SafeHydrate>
  );
}
export default App;