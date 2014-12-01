//
//  PLVRequestPersistManager.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 20.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVRequestPersistManager.h"
#import "KeychainItemWrapper.h"
#import <CommonCrypto/CommonCrypto.h>
#import "singletonHelper.h"

#define PLVInAPPSDKKeyChainPersistRequestArrayGroup @"PLVInAPPSDKKeyChainPersistRequestArrayGroup"
#define PLVInAPPSDKKeyChainPersistRequestArrayKey @"PLVInAPPSDKKeyChainPersistRequestArrayKey"

#define PLVRequestEndpointKey @"PLVRequestEndpoint"
#define PLVRequestHttpMethodKey @"PLVRequestHttpMethod"
#define PLVRequestParameterKey @"PLVRequestParameters"
#define PLVRequestFireTimeKey @"PLVRequestFireTime"
#define PLVRequestWaitIndexKey @"PLVRequestWaitIndexKey"
#define PLVRequestIdentifierKey @"PLVRequestIdentifier"


@interface PLVRequestPersistManager()

@property (strong) NSMutableArray* requestArray;
@property (strong) NSArray* repeatTimeSlotArray;
@property (nonatomic, strong) KeychainItemWrapper *keychainPersistRequests;
@property (nonatomic, strong) PLVInAppAPIClient* apiClient;

@end
@implementation PLVRequestPersistManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVRequestPersistManager);


- (instancetype)init
{
    self = [super init];
    if (self) {

        if (_requestArray == Nil) {
            _requestArray = [NSMutableArray new];
        }
        
        _repeatTimeSlotArray = @[@3,@15,@60];
        
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
    
    if (params == Nil || endpoint == Nil || method == Nil || self.apiClient == Nil) {
        return @"unvalid";
    }
    
    NSTimeInterval waitingSeconds = [[self.repeatTimeSlotArray firstObject] intValue] * 60.;
    
    NSMutableDictionary* paramDict = [NSMutableDictionary new];
    
    [paramDict setObject:endpoint forKey:PLVRequestEndpointKey];
    
    [paramDict setObject:method forKey:PLVRequestHttpMethodKey];
    
    [paramDict setObject:[NSNumber numberWithFloat:[NSDate timeIntervalSinceReferenceDate] + waitingSeconds] forKey:PLVRequestFireTimeKey];
    
    [paramDict setObject:method forKey:PLVRequestHttpMethodKey];
    
    [paramDict setObject:params forKey:PLVRequestParameterKey];
    
    [paramDict setObject:[NSNumber numberWithFloat:0] forKey:PLVRequestWaitIndexKey];
    
    
    NSString* requestTokenPhase = [self.apiClient generateHmacQueryString:(NSDictionary*)params];
    
    //4. generate hash
    const char *cKey = [self.apiClient.registerAPIKey cStringUsingEncoding:NSUTF8StringEncoding];
    
    const char *cData = [requestTokenPhase cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *requestHash = [[HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    HMAC = nil;
    
    if (requestHash == Nil || requestHash.length == 0) {
        return @"unvalid";
    }
    
    [paramDict setObject:requestHash forKey:PLVRequestIdentifierKey];
    
    [self.requestArray addObject:paramDict];
    
    [self savePersisitRequests:self.requestArray];
    
    return requestHash;
}

- (void) removeRequestFromPersistStore:(NSString*)requestToken {
    
    NSDictionary* requestToRemove;
    
    for (NSDictionary* request in self.requestArray) {
        
        if ([[request objectForKey:PLVRequestIdentifierKey] isEqualToString:requestToken]) {
            
            requestToRemove = request;
            break;
        }
    }
    
    if (requestToRemove == Nil) {
        return;
    }
    
    [self.requestArray removeObject:requestToRemove];
    
    [self savePersisitRequests:self.requestArray];
}

-(void) retryRequest:(NSDictionary*)requestDict {
    
    
    
    if (self.apiClient != Nil) {
        
        [self.apiClient startRequestWithBody:[requestDict objectForKey:PLVRequestParameterKey] addEndpoint:[requestDict objectForKey:PLVRequestEndpointKey] andHTTPMethod:[requestDict objectForKey:PLVRequestHttpMethodKey] andRequestIdentifier:[requestDict objectForKey:PLVRequestIdentifierKey]];
        
        
    }
    
}

-(NSString*) encryptDecrypt:(NSString*)toEncrypt {
    
    char key = 'q'; //Any char will work
    
    const char* encryptChar = [toEncrypt UTF8String];
    
    char* output = (char*) [toEncrypt UTF8String];
    
    for (int i = 0; i < toEncrypt.length; i++)
        output[i] = encryptChar[i] ^ key;
    
    return [NSString stringWithUTF8String:output];
}

-(NSArray*) getPersisitRequests {
    
    
#ifdef DEBUG
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
#else
    
    _keychainPersistRequests = [[KeychainItemWrapper alloc] initWithIdentifier:PLVInAPPSDKKeyChainPersistRequestArrayGroup accessGroup:Nil];
    
    return [_keychainPersistRequests objectForKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
#endif
    
}


-(void) savePersisitRequests:(NSArray*)requests {
    
    
#ifdef DEBUG
    
    [[NSUserDefaults standardUserDefaults] setObject:requests forKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

#else
    
    [self.keychainPersistRequests setObject:self.requestArray forKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
#endif
    
}

@end
