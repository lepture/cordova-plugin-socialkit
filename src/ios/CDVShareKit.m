
@import Social;
@import Accounts;

#import <Cordova/CDV.h>
#import "CDVShareKit.h"

@implementation CDVShareKit

- (void)getAccounts:(CDVInvokedUrlCommand*)command
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
}

- (void)sendRequest:(CDVInvokedUrlCommand*)command
{
}

@end
