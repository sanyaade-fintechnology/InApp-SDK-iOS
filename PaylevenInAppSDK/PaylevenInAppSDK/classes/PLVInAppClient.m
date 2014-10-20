//
//  PLVInAppClient.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//


#import "SingletonHelper.h"
#import "PLVInAppClient.h"

@interface PLVInAppClient ()

@property (strong) NSString* apiKey;
@property (strong) NSString* bundleID;

@end


@implementation PLVInAppClient

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVInAppClient)

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        
        NSLog(@"PLVInAppClient created 123456");
    }
    return self;
}

- (void) registerWithAPIKey:(NSString*)apiKey {
    
    
    
}

@end
