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
- (void) registerWithAPIKey:(NSString*)apiKey ;


/**
 *  getUsertoken
 *
 *  @param emailAddress    email Address to get the userToken for
 *  @param completionBlock completionBlock
 */

- (void) getUserToken:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  addPaymentInstruments:
 *
 *  add a array of payment instruments to a userToken
 *
 *  @param piArray           array with payment instruments
 *  @param userToken         userToken
 *  @param completionHandler completion block
 */
- (void) addPaymentInstruments:(NSArray*)piArray toUserToken:(PLVInAppUserToken*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  listPaymentInstrumentsForUserToken:
 *
 *  list the existing payment instruments for a userToken
 *
 *  @param userToken         userToken
 *  @param completionHandler completion block
 */
- (void) listPaymentInstrumentsForUserToken:(PLVInAppUserToken*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  updatePaymentInstrumentsOrder:
 *
 *  add a array of payment instruments to a userToken
 *
 *  @param piOrder           ordered set with payment instruments token hashes
 *  @param userToken         userToken
 *  @param completionHandler completion block
 */
- (void) updatePaymentInstrumentsOrder:(NSOrderedSet*)piOrder toUserToken:(PLVInAppUserToken*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

@end


