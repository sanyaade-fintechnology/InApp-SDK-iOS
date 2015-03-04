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
 *
 *  commonly used completion block to handle repsones of PLVInAppClient
 *
 *  @param response             incoming response from the api
 *  @param error                error in case of failed api call
 */

typedef void (^PLVInAppAPIClientCompletionHandler)(NSDictionary* response, NSError* error);

/** Main class to handle all actions against payleven InApp API

 Set up PLVClient in order to register your unique API key
    
 [[PLVInAppClient sharedInstance] registerWithAPIKey:@”anAPIKey”];
*/


@interface PLVInAppClient : NSObject

/**
 *  sharedInstance
 *
 *  @return Singleton PaylevenInAppCLient
 */

+ (instancetype) sharedInstance;


/**
 * PLVSDKVersion
 *
 * @return String with the version of the SDK (i.e. '1.0')
 *
 */
+ (NSString*) PLVSDKVersion;


/**
 *  registerWithAPIKey:
 *
 *  @param apiKey your API Key
 */

- (void) registerWithAPIKey:(NSString*)apiKey ;

/**
 *  createUserToken:withPaymentInstrument:useCase:andCompletion:
 *
 *  @param emailAddress         email address for userToken
 *  @param paymentInstrument    Payment Instrument to add
 *  @param useCase              useCase
 *  @param completionHandler    completionHandler
 */

- (void) createUserToken:(NSString*)emailAddress 
   withPaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
                 useCase:(PLVInAppUseCase*)useCase 
           andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  addPaymentInstrument:forUserToken:withUseCase:andCompletion:
 *
 *  add a array of payment instruments to a userToken
 *
 *  @param paymentInstrument    payment instruments to add
 *  @param userToken            userToken
 *  @param useCase              use case to add this payment instrument (optional, if empty a default usecase will be used)
 *  @param completionHandler    completion block
 */

- (void) addPaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
                 forUserToken:(PLVInAppUserToken*)userToken 
                  withUseCase:(PLVInAppUseCase*)useCase 
                andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  getPaymentInstrumentsList:withUseCase:andCompletion:
 *
 *  list the existing payment instruments for a userToken
 *
 *  @param userToken            userToken
 *  @param useCase              the useCase to list this payment instruments (optional, if empty a default usecase will be used)
 *  @param completionHandler    completion block
 */

- (void) getPaymentInstrumentsList:(PLVInAppUserToken*)userToken 
                       withUseCase:(PLVInAppUseCase*)useCase 
                     andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


/**
 *  setPaymentInstrumentsOrder:forUserToken:withUseCase:
 *
 *  add a array of paymentinstruments to a userToken
 *
 *  @param piOrder              NSOrderedSet with PaymentInstruments token hashes
 *  @param userToken            userToken
 *  @param useCase              the useCase to set the order for this payment instruments (optional, if empty a default usecase will be used)
 *  @param completionHandler    completion block
 */

- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrder 
                       forUserToken:(PLVInAppUserToken*)userToken 
                        withUseCase:(PLVInAppUseCase*)useCase 
                      andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  disablePaymentInstrument:forUserToken:andCompletion:
 *
 *  @param paymentInstrument    the paymentInstruments to disable
 *  @param userToken            userToken
 *  @param completionHandler    completionHandler
 */

- (void) disablePaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
                     forUserToken:(PLVInAppUserToken*)userToken 
                    andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

/**
 *  removePaymentInstrument:forUserToken:andCompletion:
 *
 *  @param paymentInstrument    the paymentInstrument
 *  @param userToken            userToken
 *  @param useCase              useCase to remove from
 *  @param completionHandler    completionHandler
 */

- (void) removePaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
                     fromUseCase:(NSString*)useCase 
                    forUserToken:(NSString*)userToken 
                   andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

@end


