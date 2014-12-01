//
//  PLVRequestPersistManager.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 20.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;
#import "PLVInAppAPIClient.h"

@interface PLVRequestPersistManager : NSObject


/**
 *  sharedInstance
 *
 *  @return Singleton PLVRequestPersistManager
 */

+ (instancetype) sharedInstance;


/**
 *  Register the APICLient how done the requests
 *
 *  @param apiClient
 */
- (void) registerAPIClient:(PLVInAppAPIClient*)apiClient;

/**
 *  addRequestToPersistStore
 *
 *  @param params   the parameters
 *  @param endpoint the endpoint to call
 *  @param method   the http method (get,post,delete)
 *
 *  @return requestToken (identifier) for this request
 */
- (NSString*) addRequestToPersistStore:(NSDictionary*)params toEndpoint:(NSString*)endpoint httpMethod:(NSString*)method;


/**
 *  removeRequestFromPersistStore
 *
 *  @param requestToken the Token for the request to remove
 */
- (void) removeRequestFromPersistStore:(NSString*)requestToken;

@end
