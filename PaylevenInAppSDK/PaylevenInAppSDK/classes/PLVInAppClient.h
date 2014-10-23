//
//  PLVInAppClient.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString PLVInAppUserToken;

typedef void (^PLVInAppAPIClientCompletionHandler)(NSDictionary* response, NSError* error);


@interface PLVInAppClient : NSObject


/**
 *  sharedInstance
 *
 *  @return Singleton PaylevenInAppCLient
 */

+ (instancetype) sharedInstance;



/**
 *  registerWithAPIKey:
 *
 *  @param apiKey your API Key
 */
- (void) registerWithAPIKey:(NSString*)apiKey;


/**
 *  get The Usertoken
 *
 *  @param emailAddress    email Address to get the userToken for
 *  @param completionBlock completionBlock
 */

- (void) userTokenForEmail:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;




@end


