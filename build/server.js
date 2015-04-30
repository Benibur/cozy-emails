// Generated by CoffeeScript 1.9.0
var americano, application;

americano = require('americano');

application = module.exports = function(options, callback) {
  if (options == null) {
    options = {};
  }
  options.name = 'cozy-emails';
  if (options.root == null) {
    options.root = __dirname;
  }
  if (options.port == null) {
    options.port = process.env.PORT || 9125;
  }
  if (options.host == null) {
    options.host = process.env.HOST || '127.0.0.1';
  }
  if (callback == null) {
    callback = function() {};
  }
  return americano.start(options, callback);
};

if (!module.parent) {
  application();
}
