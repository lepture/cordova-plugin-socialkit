//
// Cordova Plugin for SocialKit
//
// This plugin enables sending requests to social services with built-in
// credentials.
//
// Copyright (c) 2014 Hsiaoming Yang.
// Licensed under MIT.
//

#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Social/SLRequest.h>
#import <Social/SLServiceTypes.h>
#import <Cordova/CDV.h>
#import <Cordova/NSData+Base64.h>
#import "CDVSocialKit.h"

@interface CDVSocialKit ()

@property (nonatomic, strong) NSMutableDictionary *accountsDictionary;

- (void) getAccounts:(NSString *)socialType
         withOptions:(NSDictionary *)options
          completion:(void (^)(NSArray *accounts, NSString *error))completionHandler;

- (void) sendRequest:(NSString *)socialType
          identifier:(NSString *)identifier
              method:(NSString *)method
                 URL:(NSString *)url
          parameters:(NSDictionary *)params
                file:(NSDictionary *)file
          completion:(void (^)(NSDictionary *responseData, NSString *error))completionHandler;

- (NSArray *) formatAccounts:(NSArray *)accounts;

@end


@implementation CDVSocialKit

@synthesize accountsDictionary;


- (void) getAccounts:(CDVInvokedUrlCommand*)command
{

    NSString *socialType = [command.arguments objectAtIndex:0];
    NSDictionary *options = [command.arguments objectAtIndex:1 withDefault:nil];

    [self getAccounts:socialType withOptions:options completion:^(NSArray *accounts, NSString *error) {
        CDVPluginResult* pluginResult = nil;
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[self formatAccounts:accounts]];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


- (void) sendRequest:(CDVInvokedUrlCommand*)command {
    NSString *socialType = [command.arguments objectAtIndex:0];
    NSString *identifier = [command.arguments objectAtIndex:1];
    NSString *method = [command.arguments objectAtIndex:2];
    NSString *url = [command.arguments objectAtIndex:3];
    NSDictionary *params = [command.arguments objectAtIndex:4];
    NSDictionary *file = [command.arguments objectAtIndex:5 withDefault:nil];

    [self.commandDelegate runInBackground:^{
        [self sendRequest:socialType identifier:identifier method:method URL:url parameters:params file:file completion:^(NSDictionary *responseData, NSString *error) {
            CDVPluginResult* pluginResult = nil;
            if (responseData == nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:responseData];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void) getAccounts:(NSString *)socialType
         withOptions:(NSDictionary *)options
          completion:(void (^)(NSArray *accounts, NSString *error))completionHandler {

    NSString *identifier;

    if ([socialType isEqual:@"Facebook"]) {
        identifier = ACAccountTypeIdentifierFacebook;
    } else if ([socialType isEqual:@"SinaWeibo"]) {
        identifier = ACAccountTypeIdentifierSinaWeibo;
    } else if ([socialType isEqual:@"Twitter"]) {
        identifier = ACAccountTypeIdentifierTwitter;
    } else {
        // TODO: support TencentWeibo ?
        completionHandler(nil, @"invalid_social_type");
        return;
    }

    // nil is required for empty options
    if (options != nil && [options count] == 0) {
        options = nil;
    }

    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *socialAccountType = [accountStore accountTypeWithAccountTypeIdentifier:identifier];

    [accountStore requestAccessToAccountsWithType:socialAccountType options:options completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *socialAccounts = [accountStore accountsWithAccountType:socialAccountType];
            completionHandler(socialAccounts, nil);
        } else {
            completionHandler(nil, @"grant_denied");
        }
    }];
}

- (NSArray *) formatAccounts:(NSArray *)accounts {
    if (accounts == nil) {
        return nil;
    }

    NSMutableArray *mutableAccounts = [NSMutableArray arrayWithCapacity:[accounts count]];

    if (accountsDictionary == nil) {
        accountsDictionary = [NSMutableDictionary dictionary];
    }

    for (ACAccount *account in accounts) {
        NSString *identifier = account.identifier;
        [accountsDictionary setValue:account forKey:identifier];
        [mutableAccounts addObject:identifier];
    }

    return [mutableAccounts copy];
}

- (void) sendRequest:(NSString *)socialType
          identifier:(NSString *)identifier
              method:(NSString *)method
                 URL:(NSString *)url
          parameters:(NSDictionary *)params
                file:(NSDictionary *)file
          completion:(void (^)(NSDictionary *responseData, NSString *error))completionHandler {

    if (accountsDictionary == nil) {
        completionHandler(nil, @"no_accounts");
        return;
    }
    ACAccount *requestAccount = [accountsDictionary objectForKey:identifier];
    if (requestAccount == nil) {
        completionHandler(nil, @"invalid_identifier");
        return;
    }

    NSString *serviceType;
    if ([socialType isEqual:@"Facebook"]) {
        serviceType = SLServiceTypeFacebook;
    } else if ([socialType isEqual:@"SinaWeibo"]) {
        serviceType = SLServiceTypeSinaWeibo;
    } else if ([socialType isEqual:@"Twitter"]) {
        serviceType = SLServiceTypeTwitter;
    } else {
        completionHandler(nil, @"invalid_social_type");
        return;
    }

    NSInteger requestMethod;
    if ([method isEqual:@"GET"]) {
        requestMethod = SLRequestMethodGET;
    } else if ([method isEqual:@"POST"]) {
        requestMethod = SLRequestMethodPOST;
    } else if ([method isEqual:@"PUT"]) {
        requestMethod = SLRequestMethodPUT;
    } else if ([method isEqual:@"DELETE"]) {
        requestMethod = SLRequestMethodDELETE;
    } else {
        completionHandler(nil, @"invalid_method");
        return;
    }

    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:serviceType
                                            requestMethod:requestMethod
                                                      URL:requestURL
                                               parameters:params];

    [request setAccount:requestAccount];

    if (file != nil) {
        NSString *rawdata = [file objectForKey:@"data"];
        NSString *name = [file objectForKey:@"name"];
        NSString *type = [file objectForKey:@"type"];
        NSString *filename = [file objectForKey:@"filename"];
        NSData *data;
        if (rawdata != nil) {
            data = [NSData dataFromBase64String:rawdata];
        } else if (filename != nil) {
            // TODO: read data from filepath
        }
        if (data != nil && name != nil && type != nil) {
            [request addMultipartData:data withName:name type:type filename:filename];
        }
    }

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSError *jsonError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&jsonError];
            if (jsonError != nil) {
                completionHandler(nil, @"parse_json_error");
            } else if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                completionHandler(jsonData, nil);
            } else {
                completionHandler(jsonData, @"status_code_error");
            }
        } else {
            completionHandler(nil, @"no_response_data");
        }
    }];
}

@end
