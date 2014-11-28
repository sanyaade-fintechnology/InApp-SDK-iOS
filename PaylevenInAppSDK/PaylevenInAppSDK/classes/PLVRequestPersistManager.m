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

#define PLVRequestEndpointKey @"PLVRequestEndpoint"
#define PLVRequestHttpMethodKey @"PLVRequestHttpMethod"
#define PLVRequestRequestTimeKey @"PLVRequestTime"


@interface PLVRequestPersistManager()

@property (strong) NSMutableArray* requestArray;
@property (nonatomic, strong) KeychainItemWrapper *keychainPersistRequests;
@property (nonatomic, strong) PLVInAppAPIClient* apiClient;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;

@end
@implementation PLVRequestPersistManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVRequestPersistManager);


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _keychainPersistRequests = [[KeychainItemWrapper alloc] initWithIdentifier:PLVInAPPSDKKeyChainPersistRequestArrayGroup accessGroup:Nil];
        
        _requestArray = [_keychainPersistRequests objectForKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
        
        if (_requestArray == Nil) {
            _requestArray = [NSMutableArray new];
        }
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_dateFormatter setTimeZone:timeZone];
        _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        
    }
    return self;
}

- (void) registerAPIClient:(PLVInAppAPIClient*)apiClient {
    
    self.apiClient = apiClient;
    
    if (self.requestArray.count > 0) {
        
        // start
    }
    
}

- (NSString*) addRequestToPersistStore:(NSDictionary*)params toEndpoint:(NSString*)endpoint httpMethod:(NSString*)method {
    
    if (params == Nil || endpoint == Nil || method == Nil) {
        return @"unvalid";
    }
    
    NSMutableDictionary* paramDict = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [paramDict setObject:endpoint forKey:PLVRequestEndpointKey];
    
    [paramDict setObject:method forKey:PLVRequestHttpMethodKey];
    
    [paramDict setObject:[self.dateFormatter stringFromDate:[NSDate date]] forKey:PLVRequestRequestTimeKey];
    
//    [self.apiClient addHmacForParameterDict:paramDict];
    
    NSString* requestToken = [paramDict objectForKey:@"hmac"];
    
    if (requestToken == Nil) {
        return Nil;
    }
    
    [self.requestArray addObject:paramDict];
    
    [self.keychainPersistRequests setObject:self.requestArray forKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
    return requestToken;
}

- (void) removeRequestFromPersistStore:(NSString*)requestToken {
    
    NSDictionary* requestToRemove;
    
    for (NSDictionary* request in self.requestArray) {
        
        if ([[request objectForKey:@"hmac"] isEqualToString:requestToken]) {
            
            requestToRemove = request;
            break;
        }
    }
    
    if (requestToRemove == Nil) {
        return;
    }
    
    [self.requestArray removeObject:requestToRemove];
    
    [self.keychainPersistRequests setObject:self.requestArray forKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];

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
