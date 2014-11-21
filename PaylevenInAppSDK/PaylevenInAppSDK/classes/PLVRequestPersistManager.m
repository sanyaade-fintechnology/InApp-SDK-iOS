//
//  PLVRequestPersistManager.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 20.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVRequestPersistManager.h"
#import "KeychainItemWrapper.h"
#import "PLVInAppAPIClient.h"
#import "singletonHelper.h"

#define PLVInAPPSDKKeyChainPersistRequestArrayGroup @"PLVInAPPSDKKeyChainPersistRequestArrayGroup"
#define PLVInAPPSDKKeyChainPersistRequestArrayKey @"PLVInAPPSDKKeyChainPersistRequestArrayKey"

@interface PLVRequestPersistManager()

@property (strong) NSArray* requestArray;
@property (nonatomic, strong) KeychainItemWrapper *keychainPersistRequests;
@property (nonatomic, strong) PLVInAppAPIClient* apiClient;

@end
@implementation PLVRequestPersistManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVRequestPersistManager);


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _keychainPersistRequests = [[KeychainItemWrapper alloc] initWithIdentifier:PLVInAPPSDKKeyChainPersistRequestArrayGroup accessGroup:Nil];
        
        self.requestArray = [_keychainPersistRequests objectForKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
        
        
    }
    return self;
}

- (void) registerAPIClient:(PLVInAppAPIClient*)apiClient {
    
    self.apiClient = apiClient;
    
    if (self.requestArray.count > 0) {
        
        // start
    }
    
}

- (NSString*) addRequestToPersistStore:(NSDictionary*)params toEndpoint:(NSString*)selector httpMethod:(NSString*)method {
    
    
    
    
    return Nil;
}


-(NSString*) encryptDecrypt:(NSString*)toEncrypt {
    
    char key = 'q'; //Any char will work
    
    const char* encryptChar = [toEncrypt UTF8String];
    
    char* output = (char*) [toEncrypt UTF8String];
    
    for (int i = 0; i < toEncrypt.length; i++)
        output[i] = encryptChar[i] ^ key;
    
    return [NSString stringWithUTF8String:output];
}

@end
