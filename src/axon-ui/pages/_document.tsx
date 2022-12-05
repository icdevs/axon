import Document, { Head, Html, Main, NextScript } from "next/document";

const fullTitle = process.env.PAGE_TITLE;
const description = process.env.PAGE_TITLE;

export default class MyDocument extends Document {
  render() {
    return (
      <Html>
        <Head>
          <meta name="description" content={fullTitle} />
          <link rel="icon" href={`/img/${process.env.LOGO_ICON}`} />
          <meta property="og:type" content="website" />
          <meta name="title" content={fullTitle} />
          <meta property="og:title" content={fullTitle} />
          <meta property="twitter:title" content={fullTitle} />

          <meta name="description" content={description} />
          <meta property="og:description" content={description} />

          <meta property="twitter:card" content="summary_large_image" />
          <meta property="twitter:description" content={description} />
        </Head>
        <body>
          <Main />
          <NextScript />
        </body>
      </Html>
    );
  }
}
