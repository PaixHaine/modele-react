import React from 'react';
import Head from 'next/head';
import tachyons from 'tachyons/css/tachyons.min.css';
import stylesheet from '../src/styles/style.scss';
import Config from '../config';

const Header = () => {
  // Fonction pour obtenir le domaine Traefik pour les styles Gutenberg
  const getGutenbergBaseUrl = () => {
    // Si on est en mode Docker, on utilise le domaine Traefik
    if (process.env.HOME === '/home/node') {
      // On extrait le nom du projet de l'URL de l'API
      const apiUrl = Config.apiUrl;
      const containerName = apiUrl.match(/http:\/\/([^:]+):/)?.[1];
      if (containerName) {
        return `http://${containerName}.localdev`;
      }
    }
    // Sinon, on utilise l'URL de l'API sans /wp-json
    return Config.apiUrl.replace('/wp-json', '');
  };

  const gutenbergBaseUrl = getGutenbergBaseUrl();
  
  // URLs des styles Gutenberg
  const gutenbergStyles = [
    `${gutenbergBaseUrl}/wp-includes/css/dist/block-library/style.min.css`,
    `${gutenbergBaseUrl}/wp-includes/css/dist/block-library/theme.min.css`,
    `${gutenbergBaseUrl}/wp-includes/css/dist/block-editor/style.min.css`,
    `${gutenbergBaseUrl}/wp-includes/css/dist/format-library/style.min.css`,
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
          key={`gutenberg-${index}-${styleUrl.split('/').pop()}`}
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
