
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Social/SLRequest.h>
#import <Social/SLServiceTypes.h>
#import <Cordova/CDV.h>
#import "CDVShareKit.h"

@interface CDVShareKit ()

- (void)getAccounts:(NSString *)socialType withOptions:(NSDictionary *)options completion:(void (^)(NSArray *accounts, NSError *error))completionHandler;

@end


@implementation CDVShareKit

- (void)getAccounts:(CDVInvokedUrlCommand*)command
{

    NSString *socialType = [command.arguments objectAtIndex:0];

    [self getAccounts:socialType withOptions:nil completion:^(NSArray *accounts, NSError *error) {
        // TODO
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Grant Allow"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)sendRequest:(CDVInvokedUrlCommand*)command
{
}

- (void)getAccounts:(NSString *)socialType withOptions:(NSDictionary *)options completion:(void (^)(NSArray *accounts, NSError *error))completionHandler {

    NSString *identifier;

    // TODO: create NSError
    if ([socialType isEqual:@"Facebook"]) {
        identifier = ACAccountTypeIdentifierFacebook;
    } else if ([socialType isEqual:@"SinaWeibo"]) {
        identifier = ACAccountTypeIdentifierSinaWeibo;
    } else if ([socialType isEqual:@"Twitter"]) {
        identifier = ACAccountTypeIdentifierTwitter;
    } else {
        completionHandler(nil, nil);
        return;
    }

    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *socialAccountType = [accountStore accountTypeWithAccountTypeIdentifier:identifier];

    [accountStore requestAccessToAccountsWithType:socialAccountType options:options completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *socialAccounts = [accountStore accountsWithAccountType:socialAccountType];
            completionHandler(socialAccounts, nil);
        } else {
            completionHandler(nil, error);
        }
    }];
}

@end
