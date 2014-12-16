# cordova-plugin-socialkit

This plugin defines a global `navigator.socialkit` object, which provides
an API for requesting the social services.

Although the object is attached to the global scoped navigator, it is not
available until after the deviceready event.

```js
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    console.log(navigator.socialkit);
}
```

## Installation


## navigator.socialkit.getAccounts


## navigator.socialkit.Request
