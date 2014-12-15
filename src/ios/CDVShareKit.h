
#import <Cordova/CDVPlugin.h>

@interface CDVShareKit: CDVPlugin

- (void)getAccounts:(CDVInvokedUrlCommand*)command;

- (void)sendRequest:(CDVInvokedUrlCommand*)command;

@end
