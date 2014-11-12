//
//  PLVInAppAPIClient.h
//  PaylevenInAppSDK
//
//  Created by Alexei Kuznetsov on 01.10.14.
//  changed to PLVInAppAPIClient by ploenne 22.10.14
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import CoreLocation;
@import Foundation;

#import "PLVInAppClientTypes.h"

typedef void (^PLVInAppAPIClientCompletionHandler)(NSDictionary* response, NSError* error);

/**
 * An API client for Payleven server.
 *
 * @discussion
 * The minimum TLS version is set to 1.2.
 */
@interface PLVInAppAPIClient : NSObject

/** Queue to operate on. */
@property (nonatomic, readonly) NSOperationQueue *queue;

/** Initializes the receiver with the queue. */
- (instancetype)initWithQueue:(NSOperationQueue *)queue;

/** Performs login with the specified username and password. */
- (void)registerWithAPIKey:(NSString *)apiKey andBundleID:(NSString *)bundleID;


- (void) userTokenForEmail:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


- (void) addPaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


- (void) listPaymentInstrumentsForUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrderSet forUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;


- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(NSString*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler;

@end

