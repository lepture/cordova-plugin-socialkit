# cordova-plugin-socialkit

**WIP**

This plugin defines a `SocialKit` object, which provides an API for requesting
built-in social services.

It is not available until after the deviceready event.

```js
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    var SocialKit = cordova.require('com.lepture.socialkit.SocialKit');
    console.log(SocialKit);
}
```

## Installation

Install the plugin with `cordova`:

    cordova plugin add com.lepture.socialkit

## SocialKit.getAccounts


## SocialKit#http


## Supported Platforms

Only iOS.


## Examples

Request for weibo home timeline:

```js
SocialKit.getAccounts('SinaWeibo', {}, function(data) {
    // we just try the first account
    var account = data[0];
    var req = new SocialKit('SinaWeibo', account);
    req.get('https://api.weibo.com/2/statuses/home_timeline.json', {}, null, console.log);
});
```
