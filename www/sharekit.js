/**
 * Share Kit
 */

var exec = require('cordova/exec');


function Request(options) {
  options = options || {};
  this.type = options.type;
  this.account = options.account;
}

/** Fetch social accounts of a certain type */
Request.accounts = function(type, options, callback, errorhandler) {
  errorhandler = errorhandler || echoError;
  exec(callback, errorhandler, 'ShareKit', 'getAccounts', [type, options]);
};

/** Send http request */
Request.prototype.http = function(method, url, params, callback, errorhandler) {
  errorhandler = errorhandler || echoError;
  exec(callback, errorhandler, 'ShareKit', 'sendRequest', [
       this.type, this.account, method, url, params
  ]);
};

/** Alias for GET http request. */
Request.prototype.get = function(url, params, callback, errorhandler) {
  this.http('GET', url, params, callback, errorhandler);
};

/** Alias for POST http request. */
Request.prototype.post = function(url, params, callback, errorhandler) {
  this.http('POST', url, params, callback, errorhandler);
};

/** Alias for PUT http request. */
Request.prototype.put = function(url, params, callback, errorhandler) {
  this.http('PUT', url, params, callback, errorhandler);
};

/** Alias for DELETE http request. */
Request.prototype.delete = function(url, params, callback, errorhandler) {
  this.http('DELETE', url, params, callback, errorhandler);
};

function echoError(err) {
  console.error(err);
}

module.exports = Request;
