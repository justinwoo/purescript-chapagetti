var React = require('react');
var ReactRedux = require('react-redux');

exports._reduxProvider = function (store, child) {
  return React.createElement(
    ReactRedux.Provider,
    {store: store},
    child
  );
};

exports._connect = ReactRedux.connect;
