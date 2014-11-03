//
//  PLVInAppClient.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//


#import "SingletonHelper.h"
#import "PLVInAppClient.h"
#import "PLVInAppAPIClient.h"
#import "PLVInAppSDKConstants.h"

@interface PLVInAppClient ()

@property (strong) NSString* apiKey;
@property (strong) NSString* bundleID;

/** Serial operation queue. */
@property (nonatomic, strong) NSOperationQueue *queue;

/** API client. */
@property (nonatomic, strong) PLVInAppAPIClient *inAppAPIClient;

@end


@implementation PLVInAppClient

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVInAppClient)

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        
        SDLog(@"PLVInAppClient created 123456 BundleID: %@",_bundleID);
        
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name = NSStringFromClass([self class]);
        _inAppAPIClient = [[PLVInAppAPIClient alloc] initWithQueue:_queue];
        
    }
    return self;
}

- (void) registerWithAPIKey:(NSString*)apiKey {
    
    assert(apiKey);
    
    [self.inAppAPIClient registerWithAPIKey:apiKey andBundleID:self.bundleID];
    
}

- (void) getUserToken:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    [self.inAppAPIClient userTokenForEmail:emailAddress withCompletion:completionHandler];
    
}

- (void) addPaymentInstruments:(NSArray*)piArray forUserToken:(PLVInAppUserToken*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    [self.inAppAPIClient addPaymentInstruments:piArray forUserToken:userToken withCompletion:completionHandler];
}

- (void) listPaymentInstrumentsForUserToken:(PLVInAppUserToken*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    [self.inAppAPIClient listPaymentInstrumentsForUserToken:userToken withCompletion:completionHandler];
}

- (void) updatePaymentInstrumentsOrder:(NSOrderedSet*)piOrder toUserToken:(PLVInAppUserToken*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    
    
}


@end
