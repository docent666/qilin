import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import 'babel-polyfill';

import App from 'views/Exchange';

import es6Promise from 'es6-promise';
import 'isomorphic-fetch';
import getWeb3 from 'utils/getWeb3'

// Load SCSS
//import 'purecss/build/pure.css';

es6Promise.polyfill();

const render = Component => {
  ReactDOM.render(
    <AppContainer>
        <Component />
    </AppContainer>,
    document.getElementById('exchange')
  );
};

// Render app
render(App);

if (module.hot) {
  module.hot.accept('./views/Exchange/', () => {
    const NewApp = require('./views/Exchange/index').default; // eslint-disable-line global-require
    render(NewApp);
  });
}
