import React from 'react';
import Head from 'next/head';
import tachyons from 'tachyons/css/tachyons.min.css';
import stylesheet from '../src/styles/style.scss';
import Config from '../config';

const Header = () => {
  // URLs des styles Gutenberg
  const gutenbergStyles = [
    `${Config.apiUrl.replace('/wp-json', '')}/wp-includes/css/dist/block-library/style.min.css`,
    `${Config.apiUrl.replace('/wp-json', '')}/wp-includes/css/dist/block-library/theme.min.css`,
    `${Config.apiUrl.replace('/wp-json', '')}/wp-includes/css/dist/block-editor/style.min.css`,
    `${Config.apiUrl.replace('/wp-json', '')}/wp-includes/css/dist/format-library/style.min.css`,
  ];

  return (
    <Head>
      <style
        // eslint-disable-next-line react/no-danger
        dangerouslySetInnerHTML={{ __html: tachyons }}
      />
      <style
        // eslint-disable-next-line react/no-danger
        dangerouslySetInnerHTML={{ __html: stylesheet }}
      />
      {/* Styles de Gutenberg */}
      {gutenbergStyles.map((styleUrl, index) => (
        <link 
          key={`gutenberg-${index}`}
          rel="stylesheet" 
          href={styleUrl}
          media="all"
        />
      ))}
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <meta charSet="utf-8" />
      <title>WordPress + React Starter Kit Frontend by Postlight</title>
    </Head>
  );
};

export default Header;
