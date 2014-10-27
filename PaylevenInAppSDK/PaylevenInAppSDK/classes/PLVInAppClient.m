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
        
        NSLog(@"PLVInAppClient created 123456 BundleID: %@",_bundleID);
        
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name = NSStringFromClass([self class]);
        _inAppAPIClient = [[PLVInAppAPIClient alloc] initWithQueue:_queue];
        
    }
    return self;
}

- (void) registerWithAPIKey:(NSString*)apiKey {
    
    assert(apiKey);
    
    [self.inAppAPIClient registerWithAPIKey:apiKey andBundleID:self.bundleID completionHandler:^(NSDictionary* response,NSError *error) {
        
        NSLog(@"Response %@",response);
        NSLog(@"Error %@",error);
        
    }];
    
}

- (void) userTokenForEmail:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    [self.inAppAPIClient userTokenForEmail:emailAddress withCompletion:completionHandler];
    
}

@end
