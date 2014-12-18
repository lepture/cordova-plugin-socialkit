/**
 * Social Kit
 */

var exec = require('cordova/exec');

// factory cache
var ref = {};

/** Service interface */
function Service(type, identifier, options) {
  if (!(this instanceof Service)) {
    if (ref[identifier]) return ref[identifier];
    var instance = new Service(type, identifier, options);
    ref[identifier] = instance;
    return instance;
  }
  if (!type || !identifier) {
    throw new Error('type and identifier are required');
  }
  this.type = type;
  this.identifier = identifier;
  this.options = options || {};
}


/** Fetch social identifiers of a certain type */
Service.getIdentifiers = function(type, options, callback, errorhandler) {
  errorhandler = errorhandler || echoError;
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

  // Make sure all params are strings
  Object.keys(params).forEach(function(key) {
    params[key] = params[key].toString();
  });

  file = file || {};

  // define formatURL
  if (this.formatURL && !/^http:\/\//.test(url)) {
    url = this.formatURL(url);
  }

  exec(callback, errorhandler, 'SocialKit', 'sendRequest', [
       this.type, this.identifier, method, url, params, file, this.options,
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
