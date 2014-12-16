
#import <Cordova/CDVPlugin.h>

@interface CDVSocialKit: CDVPlugin

- (void)getAccounts:(CDVInvokedUrlCommand*)command;

- (void)sendRequest:(CDVInvokedUrlCommand*)command;

@end
