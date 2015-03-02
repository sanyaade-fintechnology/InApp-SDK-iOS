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

/**
 *  PLVInAppAPIClientCompletionHandler
 *
 *  the common completion block to habdle repsones of the api client
 *
 *  @param response             incoming response from the api
 *  @param error                error in case of failed api call
 */

typedef void (^PLVInAppAPIClientCompletionHandler)(NSDictionary* response, NSError* error);

/**
 *  PLVInAppClient
 *
 *  main class to handle all actions against payleven InApp API
 *
 */

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
 *  @param payInstrument     the payment instruments to add
 *  @param userToken         userToken
 *  @param useCase           the useCase to add this payment instrument (optional, if empty a default usecase will be used)
 *  @param completionHandler completion block
 */
- (void) addPaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  listPaymentInstrumentsForUserToken:
 *
 *  list the existing payment instruments for a userToken
 *
 *  @param userToken         userToken
 *  @param useCase           the useCase to list this payment instruments (optional, if empty a default usecase will be used)
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
 *  @param useCase           the useCase to set the order for this payment instruments (optional, if empty a default usecase will be used)
 *  @param completionHandler completion block
 */
- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrder forUserToken:(PLVInAppUserToken*)userToken  withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  disablePaymentInstruments
 *
 *  @param payInstrument     the paymentInstruments to disable
 *  @param userToken         userToken
 *  @param completionHandler completionHandler
 */
- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  removePaymentInstrument
 *
 *  @param payInstrument     the paymentInstrument
 *  @param userToken         userToken
 *  @param useCase           useCase to remove from
 *  @param completionHandler completionHandler
 */

- (void) removePaymentInstrument:(PLVPaymentInstrument*)payInstrument fromUseCase:(NSString*)useCase forUserToken:(NSString*)userToken  andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

@end


