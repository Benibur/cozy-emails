// Generated by CoffeeScript 1.8.0
var Any, Settings, americano, _;

americano = require('americano-cozy');

_ = require('lodash');

Any = function(x) {
  return x;
};

module.exports = Settings = americano.getModel('MailsSettings', {
  messagesPerPage: {
    type: Number,
    "default": 25
  },
  refreshInterval: {
    type: Number,
    "default": 5
  },
  displayConversation: {
    type: Boolean,
    "default": true
  },
  displayPreview: {
    type: Boolean,
    "default": true
  },
  composeInHTML: {
    type: Boolean,
    "default": true
  },
  messageDisplayHTML: {
    type: Boolean,
    "default": true
  },
  messageDisplayImages: {
    type: Boolean,
    "default": false
  },
  messageConfirmDelete: {
    type: Boolean,
    "default": true
  },
  lang: {
    type: String,
    "default": 'en'
  },
  listStyle: {
    type: String,
    "default": 'default'
  },
  plugins: {
    type: Any,
    "default": null
  }
});

Settings.getInstance = function(callback) {
  return Settings.request('all', function(err, settings) {
    var existing;
    if (err) {
      return callback(err);
    }
    existing = settings != null ? settings[0] : void 0;
    if (existing) {
      return callback(null, existing);
    } else {
      return callback(null, new Settings());
    }
  });
};

Settings.get = function(callback) {
  return Settings.getInstance(function(err, instance) {
    return callback(err, instance != null ? instance.toObject() : void 0);
  });
};

Settings.set = function(changes, callback) {
  return Settings.getInstance(function(err, instance) {
    if (err) {
      return callback(err);
    }
    return instance.updateAttributes(changes, callback);
  });
};
