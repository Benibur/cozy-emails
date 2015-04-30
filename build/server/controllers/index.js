// Generated by CoffeeScript 1.9.0
var Account, CONSTANTS, Contact, ImapReporter, Settings, async, cozydb, log;

ImapReporter = require('../imap/reporter');

Account = require('../models/account');

Contact = require('../models/contact');

Settings = require('../models/settings');

CONSTANTS = require('../utils/constants');

async = require('async');

cozydb = require('cozydb');

log = require('../utils/logging')({
  prefix: 'controllers:index'
});

module.exports.main = function(req, res, next) {
  return async.series([
    function(cb) {
      return Settings.getDefault(cb);
    }, function(cb) {
      return cozydb.api.getCozyLocale(cb);
    }, function(cb) {
      return Account.clientList(cb);
    }, function(cb) {
      return Contact.requestWithPictures('all', {}, cb);
    }
  ], function(err, results) {
    var accounts, contacts, imports, locale, refreshes, settings;
    refreshes = ImapReporter.summary();
    if (err) {
      log.error(err.stack);
      imports = "console.log(\"" + err + "\");\nwindow.locale = \"en\"\nwindow.refreshes = []\nwindow.accounts  = []\nwindow.contacts  = []";
    } else {
      settings = results[0], locale = results[1], accounts = results[2], contacts = results[3];
      imports = "window.settings  = " + (JSON.stringify(settings)) + "\nwindow.refreshes = " + (JSON.stringify(refreshes)) + ";\nwindow.locale    = \"" + locale + "\";\nwindow.accounts  = " + (JSON.stringify(accounts)) + ";\nwindow.contacts  = " + (JSON.stringify(contacts)) + ";";
    }
    return res.render('index.jade', {
      imports: imports
    });
  });
};

module.exports.refresh = function(req, res, next) {
  var limitByBox, onlyFavorites, _ref;
  if ((_ref = req.query) != null ? _ref.all : void 0) {
    limitByBox = null;
    onlyFavorites = false;
  } else {
    limitByBox = CONSTANTS.LIMIT_BY_BOX;
    onlyFavorites = true;
  }
  return Account.refreshAllAccounts(limitByBox, onlyFavorites, function(err) {
    if (err) {
      log.error("REFRESHING ACCOUNT FAILED", err);
    }
    if (err) {
      return next(err);
    }
    return res.send({
      refresh: 'done'
    });
  });
};

module.exports.refreshes = function(req, res, next) {
  return res.send(ImapReporter.summary());
};
