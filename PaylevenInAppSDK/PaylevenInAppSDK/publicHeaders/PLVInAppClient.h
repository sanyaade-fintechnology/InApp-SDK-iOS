//
//  PLVInAppClient.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLVPaymentInstrument;

typedef NSString PLVInAppUserToken;
typedef NSString PLVInAppUseCase;

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
 *  @param apiKey your API Key, and register specific baseServiceURL
 */
- (void) registerWithAPIKey:(NSString*)apiKey andSpecificBaseServiceURL:(NSString*)serviceURLString;

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
 *  createUserToken:
 *
 *  @param emailAddress      email address for userToken
 *  @param payInstrument     payment instrument to add
 *  @param useCase           useCase
 *  @param completionHandler completionHandler
 */
- (void) createUserToken:(NSString*)emailAddress withPaymentInstrument:(PLVPaymentInstrument*)payInstrument useCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  addPaymentInstrument:
 *
 *  add a array of payment instruments to a userToken
 *
 *  @param piArray           array with payment instruments
 *  @param userToken         userToken
 *  @param completionHandler completion block
 */
- (void) addPaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  listPaymentInstrumentsForUserToken:
 *
 *  list the existing payment instruments for a userToken
 *
 *  @param userToken         userToken
 *  @param completionHandler completion block
 */
- (void) getPaymentInstrumentsList:(PLVInAppUserToken*)userToken withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  updatePaymentInstrumentsOrder:
 *
 *  add a array of payment instruments to a userToken
 *
 *  @param piOrder           NSOrderedSet with PaymentInstruments token hashes
 *  @param userToken         userToken
 *  @param completionHandler completion block
 */
- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrder forUserToken:(PLVInAppUserToken*)userToken  withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  disablePaymentInstruments
 *
 *  @param piArray           Array with PaymentInstruments
 *  @param userToken         userToken
 *  @param completionHandler completionHandler
 */
- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  removePaymentInstrument
 *
 *  @param payInstrument     PaymentInstruments
 *  @param userToken         userToken
 *  @param useCase           useCase to remove from
 *  @param completionHandler completionHandler
 */

- (void) removePaymentInstrument:(PLVPaymentInstrument*)payInstrument fromUseCase:(NSString*)useCase forUserToken:(NSString*)userToken  andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

@end


