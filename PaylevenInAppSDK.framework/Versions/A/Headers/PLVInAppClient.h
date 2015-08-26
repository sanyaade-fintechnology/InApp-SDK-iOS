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
//typedef NSString PLVInAppUseCase;

/**
 *
 *  completion block to handle create UserToken repsones of PLVInAppClient
 *
 *  @param userToken            created User Token, if nil check error
 *  @param error                error in case of failed api call
 */
typedef void (^PLVInAppClientCreateUserTokenCompletionHandler)(NSString* userToken, NSError* error);

/**
 *
 *  completion block to handle Add Payment Instrument repsone of PLVInAppClient
 *
 *  @param error                nil when successful, error in case of failed api call
 */
typedef void (^PLVInAppClientAddPaymentInstrumentCompletionHandler)(NSError* error);

/**
 *
 *  completion block to handle Get Payment Instrument  repsone of PLVInAppClient
 *
 *  @param paymentInstrumentsArray  Array containing objects of PLVPaymentInstrument, can also be count 0, if nil check error
 *  @param error                    error in case of failed api call
 */
typedef void (^PLVInAppAPIClientGetPaymentInstrumentListCompletionHandler)(NSArray * paymentInstrumentsArray, NSError* error);

/**
 *
 *  completion block to handle Set Payment Instrument order repsone of PLVInAppClient
 *
 *  @param error                nil when successful, error in case of failed api call
 */
typedef void (^PLVInAppAPIClientSetPaymentInstrumentOrderCompletionHandler)(NSError* error);

/**
 *
 *  completion block to handle Disable Payment Instrument repsone of PLVInAppClient
 *
 *  @param error                nil when successful, error in case of failed api call
 */
typedef void (^PLVInAppAPIClientDisablePaymentInstrumentCompletionHandler)(NSError* error);

/**
 *
 *  completion block to handle Remove Payment Instrument repsone of PLVInAppClient
 *
 *  @param error                nil when successful, error in case of failed api call
 */
typedef void (^PLVInAppAPIClientRemovePaymentInstrumentCompletionHandler)(NSError* error);

/** Main class to handle all actions against payleven InApp API

 In order to start working with the Payleven InApp SDK, an instance of the PLVInAppClient is required.
 Retrieve it using the singleton instance using the sharedInstance class method. 
 Next, set up the instance with your API Key using the registerWithAPIKey: method.
 [[PLVInAppClient sharedInstance] registerWithAPIKey:@”anAPIKey”];
 
 Before offering your business services, call getPaymentInstrumentsList:andCompletion: to make sure that the user has at least one valid (not expired) payment instrument.
*/


@interface PLVInAppClient : NSObject

/**
 *  sharedInstance
 *
 *  @return Singleton PaylevenInAppClient
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
 *  Associates the singleton Object with your API Key
 *
 *  @param apiKey your API Key
 *
 */
- (void) registerWithAPIKey:(NSString*)apiKey ;

/**
 *  Creates a user token based on the email address provided and adds the payment instrument to the user token previously created
 *
 *  @param emailAddress         email address for userToken
 *  @param paymentInstrument    Payment Instrument to add
 *  @param completionHandler    completionHandler
 */

- (void) createUserToken:(NSString*)emailAddress 
   withPaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
           andCompletion:(PLVInAppClientCreateUserTokenCompletionHandler)completionHandler;

/**
 *  addPaymentInstrument:forUserToken:andCompletion:
 *
 *  Associates a payment instrument to a user token
 *
 *  @param paymentInstrument    payment instruments to add
 *  @param userToken            userToken
 *  @param completionHandler    completion block
 */

- (void) addPaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
                 forUserToken:(PLVInAppUserToken*)userToken 
                andCompletion:(PLVInAppClientAddPaymentInstrumentCompletionHandler)completionHandler;


/**
 *  getPaymentInstrumentsList:andCompletion:
 *
 *  Retrieves the list of payment instruments associated to a user token. The payment instruments returned are sorted based on the order used when making a payment
 *
 *  @param userToken            userToken
 *  @param completionHandler    completion block
 */

- (void) getPaymentInstrumentsList:(PLVInAppUserToken*)userToken 
                     andCompletion:(PLVInAppAPIClientGetPaymentInstrumentListCompletionHandler)completionHandler;


/**
 *  setPaymentInstrumentsOrder:forUserToken:
 *
 *  Sets the order of payment instruments for a user token. 
 *  The order of the payment instruments in the list will represent the order in which the payment instruments will be used when making a payment
 *
 *  @param piOrder              NSOrderedSet with PaymentInstruments token hashes
 *  @param userToken            userToken
 *  @param completionHandler    completion block
 */

- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrder 
                       forUserToken:(PLVInAppUserToken*)userToken 
                      andCompletion:(PLVInAppAPIClientSetPaymentInstrumentOrderCompletionHandler)completionHandler;

/**
 *  disablePaymentInstrument:forUserToken:andCompletion:
 *
 *  Disables a payment instrument of a specified user token.
 *  The disabled payment instrument will not be used for making payments anymore.
 *
 *  @param paymentInstrument    the paymentInstruments to disable
 *  @param userToken            userToken
 *  @param completionHandler    completionHandler
 */

- (void) disablePaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
                     forUserToken:(PLVInAppUserToken*)userToken 
                    andCompletion:(PLVInAppAPIClientDisablePaymentInstrumentCompletionHandler)completionHandler;

/**
 *  removePaymentInstrument:fromUseCase:forUserToken:andCompletion:
 *
 *  Removes a payment instrument associated to a user token from a use case.
 *
 *  @param paymentInstrument    the paymentInstrument
 *  @param userToken            userToken
 *  @param useCase              useCase to remove from
 *  @param completionHandler    completionHandler
 */

//- (void) removePaymentInstrument:(PLVPaymentInstrument*)paymentInstrument 
//                     fromUseCase:(NSString*)useCase 
//                    forUserToken:(NSString*)userToken 
//                   andCompletion:(PLVInAppAPIClientRemovePaymentInstrumentCompletionHandler)completionHandler;

@end


