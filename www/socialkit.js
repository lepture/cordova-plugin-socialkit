/**
 * Social Kit
 */

var exec = require('cordova/exec');


/** Service interface */
function Service(type, account) {
  if (!(this instanceof Service)) {
    return new Service(type, account);
  }
  this.type = type;
  this.account = account;
}


/** Fetch social accounts of a certain type */
Service.getAccounts = function(type, options, callback, errorhandler) {
  if (typeof(options) === 'function') {
    callback = options;
    errorhandler = callback;
    options = null;
  }
  errorhandler = errorhandler || echoError;
  options = options || {};
  exec(callback, errorhandler, 'SocialKit', 'getAccounts', [type, options]);
};


/** Send http request */
Service.prototype.http = function(method, url, params, file, callback, errorhandler) {
  if (typeof(params) === 'function') {
    callback = params;
    errorhandler = file;
    params = {};
    file = {};
  } else if (typeof(file) === 'function') {
    callback = file;
    errorhandler = callback;
    file = {};
  }

  errorhandler = errorhandler || echoError;
  params = params || {};
  file = file || {};
  exec(callback, errorhandler, 'SocialKit', 'sendRequest', [
       this.type, this.account, method, url, params, file
  ]);
};

/** Alias for GET http request. */
Service.prototype.get = function(url, params, file, callback, errorhandler) {
  this.http('GET', url, params, file, callback, errorhandler);
};

/** Alias for POST http request. */
Service.prototype.post = function(url, params, file, callback, errorhandler) {
  this.http('POST', url, params, file, callback, errorhandler);
};

/** Alias for PUT http request. */
Service.prototype.put = function(url, params, file, callback, errorhandler) {
  this.http('PUT', url, params, file, callback, errorhandler);
};

/** Alias for DELETE http request. */
Service.prototype.delete = function(url, params, file, callback, errorhandler) {
  this.http('DELETE', url, params, file, callback, errorhandler);
};

function echoError(err) {
  console.error(err);
}

module.exports = Service;
