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
#import "PLVInAppSDKConstants.h"

#define PLVInAPPSDKKeyChainPersistRequestArrayGroup @"PLVInAPPSDKKeyChainPersistRequestArrayGroup"
#define PLVInAPPSDKKeyChainPersistRequestArrayKey @"PLVInAPPSDKKeyChainPersistRequestArrayKey"

#define PLVRequestEndpointKey @"PLVRequestEndpoint"
#define PLVRequestHttpMethodKey @"PLVRequestHttpMethod"
#define PLVRequestParameterKey @"PLVRequestParameters"
#define PLVRequestFireTimeKey @"PLVRequestFireTime"
#define PLVRequestWaitingSlotKey @"PLVRequestWaitingSlotKey"
#define PLVRequestIdentifierKey @"PLVRequestIdentifier"

#define kRepeatCheckIntervall 5.

NSInteger alphabeticKeySort(id string1, id string2, void *reverse);

@interface PLVRequestPersistManager()

@property (strong) NSMutableArray* requestArray;
@property (strong) NSArray* waitingSlotLenghtArray;
@property (nonatomic, strong) KeychainItemWrapper *keychainPersistRequests;
@property (nonatomic, strong) PLVInAppAPIClient* apiClient;
@property (nonatomic, strong) NSTimer* requestRetryTimer;

@end
@implementation PLVRequestPersistManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVRequestPersistManager);


- (instancetype)init
{
    self = [super init];
    if (self) {

        _requestArray = [self loadPersisitRequests];

        _waitingSlotLenghtArray = @[@15,@60,@180];
        
    }
    return self;
}

- (void) registerAPIClient:(PLVInAppAPIClient*)apiClient {
    
    self.apiClient = apiClient;
    
    if (self.requestArray.count > 0) {
        
        // start
        
        self.requestRetryTimer = [NSTimer scheduledTimerWithTimeInterval:kRepeatCheckIntervall target:self selector:@selector(checkRetryTiming) userInfo:Nil repeats:YES];
    }
}

- (void) checkRetryTiming {
    
    if (self.requestArray.count == 0 ) {
       [self.requestRetryTimer invalidate];
    }
    
    SDLog (@"Check RepeatRequest");
    
    NSTimeInterval nowTimeStamp = [NSDate timeIntervalSinceReferenceDate];
    
    NSMutableArray* runNowRequest = [NSMutableArray new];
    
    for (NSDictionary* request in self.requestArray) {
        
        if ([[request objectForKey:PLVRequestFireTimeKey] floatValue] < nowTimeStamp) {
            [runNowRequest addObject:request];
        }
    }
    
    for (NSDictionary* request in runNowRequest) {
        [self retryRequest:request];
    }
    
}

- (void) fireImmediately {
    
    @synchronized(self) {
    
    NSMutableArray* runNowRequest = [NSMutableArray new];
    
    for (NSDictionary* request in self.requestArray) {
        [runNowRequest addObject:request];
    }
    
    for (NSDictionary* request in runNowRequest) {
        [self retryRequest:request];
    }
        
    }
    
}



- (NSString*) addRequestToPersistStore:(NSDictionary*)params toEndpoint:(NSString*)endpoint httpMethod:(NSString*)method {
    
    if (params == Nil || endpoint == Nil || method == Nil || self.apiClient == Nil) {
        return @"unvalid";
    }
    
    NSTimeInterval waitingSeconds = [[self.waitingSlotLenghtArray firstObject] floatValue] * 60.;
    
    NSMutableDictionary* paramDict = [NSMutableDictionary new];
    
    [paramDict setObject:endpoint forKey:PLVRequestEndpointKey];
    
    [paramDict setObject:method forKey:PLVRequestHttpMethodKey];
    
    [paramDict setObject:method forKey:PLVRequestHttpMethodKey];
    
    [paramDict setObject:params forKey:PLVRequestParameterKey];
    
    NSString* requestTokenPhase = [self generateHmacQueryString:(NSDictionary*)params];
    
    // execlude repeatSlot and firetime from hash creation
    
    [paramDict setObject:[NSNumber numberWithUnsignedLong:0] forKey:PLVRequestWaitingSlotKey];
    
    [paramDict setObject:[NSNumber numberWithFloat:[NSDate timeIntervalSinceReferenceDate] + waitingSeconds] forKey:PLVRequestFireTimeKey];
    
    
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
    
    if (!self.requestRetryTimer.isValid) {
        self.requestRetryTimer = [NSTimer scheduledTimerWithTimeInterval:kRepeatCheckIntervall target:self selector:@selector(checkRetryTiming) userInfo:Nil repeats:YES];
    }
    
    return requestHash;
}

- (void) removeRequestFromPersistStore:(NSString*)requestToken {
    
    @synchronized(self) {
        
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
    
}

-(void) retryRequest:(NSDictionary*)requestDict {
    
    if (self.apiClient != Nil) {
        
        @synchronized(self) {
            
            NSMutableDictionary* requestToRun = [NSMutableDictionary dictionaryWithDictionary:requestDict];
            
            unsigned long repeatSlot = [[requestDict objectForKey:PLVRequestWaitingSlotKey] unsignedLongValue];
            
            repeatSlot++;
            
            if (repeatSlot >= self.waitingSlotLenghtArray.count) {
                repeatSlot = self.waitingSlotLenghtArray.count - 1;
            }
            
            float waitingSlotLength = [[self.waitingSlotLenghtArray objectAtIndex:repeatSlot] floatValue] * 60.;
            
            [requestToRun setObject:[NSNumber numberWithFloat:[NSDate timeIntervalSinceReferenceDate] + waitingSlotLength] forKey:PLVRequestFireTimeKey];
            
            [requestToRun setObject:[NSNumber numberWithUnsignedLong:repeatSlot] forKey:PLVRequestWaitingSlotKey];
            
            [self.requestArray removeObject:requestDict];
            
            [self.requestArray addObject:requestToRun];
            
            [self savePersisitRequests:self.requestArray];
            
            [self.apiClient startRequestWithBody:[requestToRun objectForKey:PLVRequestParameterKey] addEndpoint:[requestToRun objectForKey:PLVRequestEndpointKey] andHTTPMethod:[requestToRun objectForKey:PLVRequestHttpMethodKey] andRequestIdentifier:[requestToRun objectForKey:PLVRequestIdentifierKey]];
            
        }

    }
    
}


-(NSArray*) loadPersisitRequests {
    
    return [NSMutableArray new];
    
    // currently we don't save our request do disk
    
#ifdef DEBUG
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
#else
    
    _keychainPersistRequests = [[KeychainItemWrapper alloc] initWithIdentifier:PLVInAPPSDKKeyChainPersistRequestArrayGroup accessGroup:Nil];
    
    return [_keychainPersistRequests objectForKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
#endif
    
}


-(void) savePersisitRequests:(NSArray*)requests {
    
    return;
    
    // currently we don't save our request do disk
    
#ifdef DEBUG
    
    [[NSUserDefaults standardUserDefaults] setObject:requests forKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

#else
    
    [self.keychainPersistRequests setObject:self.requestArray forKey:PLVInAPPSDKKeyChainPersistRequestArrayKey];
    
#endif
    
}

-(NSString *)generateHmacQueryString:(NSDictionary *)params
{
    /*
     Convert an NSDictionary to a query string
     */
    
    NSMutableArray* pairs = [NSMutableArray array];
    
    //sort params alphabetically
    NSArray *paramKeys = [params allKeys];
    BOOL reverseSort = NO;
    NSArray *sortedParamKeys = [paramKeys sortedArrayUsingFunction:alphabeticKeySort context:&reverseSort];
    
    //generate query string by taking subarrays and dictionarys into account
    for (NSString* key in sortedParamKeys)
    {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* valueDict = (NSDictionary*)value;
            
            NSArray* keyArray = [valueDict.allKeys sortedArrayUsingFunction:alphabeticKeySort context:&reverseSort];
            
            for (NSString *subKey in keyArray)
            {
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, [value objectForKey:subKey]]];
            }
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            NSUInteger i = 0;
            
            for (NSString *subValue in value)
            {
                if ([subValue isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary* subValueDict = (NSDictionary*)subValue;
                    
                    NSArray* keyArray = [subValueDict.allKeys sortedArrayUsingFunction:alphabeticKeySort context:&reverseSort];
                    
                    for (NSString *subKey in keyArray)
                    {
                        [pairs addObject:[NSString stringWithFormat:@"%@[%lu][%@]=%@", key,(unsigned long)i, subKey, [subValueDict objectForKey:subKey]]];
                    }
                } else {
                    
                    [pairs addObject:[NSString stringWithFormat:@"%@[%lu]=%@", key, (unsigned long)i, subValue]];
                    
                }
                
                i++;
            }
        }
        else
        {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

@end



NSInteger alphabeticKeySort(id string1, id string2, void *reverse)
{
    if (*(BOOL *)reverse == YES)
    {
        return [string2 localizedCaseInsensitiveCompare:string1];
    }
    return [string1 localizedCaseInsensitiveCompare:string2];
}

