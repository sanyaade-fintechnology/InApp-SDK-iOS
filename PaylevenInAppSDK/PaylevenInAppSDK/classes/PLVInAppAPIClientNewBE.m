//
//  PLVInAppAPIClientNewBE.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 01.10.14.
//  changed to PLVInAppAPIClient by ploenne 22.10.14
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVInAppAPIClient.h"

#import "PLVServerCertificate.h"
#import "PLVServerTrustValidator.h"
#import "PLVInAppSDKConstants.h"
#import "PLVInAppErrors.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "OrderedDictionary.h"
#import "PLVRequestPersistManager.h"
#import <CommonCrypto/CommonCrypto.h>
#import "UIDevice+Platform.h"

#define useLocalEndpoint 0
#define usemacMiniEndpoint 0
#define useOtherEndpoint 1

#define apiParameterKeyEmail @"email"
#define apiParameterKeyUserToken @"userToken"
#define apiParameterPIIdentifier @"identifier"
#define apiParameterKeyAddPIs @"paymentInstruments"
#define apiParameterKeyPI @"paymentInstrument"
#define apiParameterKeyUseCase @"useCase"


#define apiHeaderKeyXHmacTimeStamp @"X-Hmac-Timestamp"
#define apiHeaderKeyXHmac @"X-Hmac"
#define apiHeaderKeyXBundleID @"X-Bundle-ID"
#define apiHeaderKeyXSDKVersion @"X-Sdk-Version"
#define apiHeaderKeyXOSVersion @"X-OS-Version"
#define apiHeaderKeyXDeviceType @"X-Device-Model"
#define apiHeaderKeyXAuthType @"X-Authorization"


#define httpMethodePOST @"POST"
#define httpMethodeGET @"GET"
#define httpMethodeDELETE @"DELETE"


#define PLVInAppClientAPIUsersEndPoint @"/users"
#define PLVInAppClientAPIUsersAddPiEndPoint @"/users/%@/paymentinstruments"
#define PLVInAppClientAPIListPisEndPoint @"/users/%@/paymentinstruments/%@"
#define PLVInAppClientAPISetPiListOrderEndPoint @"/users/%@/paymentinstruments"
#define PLVInAppClientAPIUsersDisablePiEndPoint @"/users/%@/paymentinstruments/%@"
#define PLVInAppClientAPIRemovePiForUseCaseEndPoint @"/users/%@/paymentinstruments/%@/use-case/%@"


#if useLocalEndpoint
/** locahost endpoint. */

static NSString * const PLVInAppClientAPIHost = @"http://localhost/staging/api";

#elif usemacMiniEndpoint

/** macMini in office endpoint. */

static NSString * const PLVInAppClientAPIHost = @"http://10.15.100.130:8888/staging/api";


#elif useOtherEndpoint

static NSString * const PLVInAppClientAPIHost = @"http://192.168.32.56/staging/api";

#else

/** staging endpoint */

static NSString * const PLVInAppClientAPIHost = @"https://apiproxy-staging.payleven.de";

#endif


static NSString * const PLVInAppSDKVersion = @"1.0";
NSInteger alphabeticKeySort(id string1, id string2, void *reverse);

@interface PLVInAppAPIClient () <NSURLSessionTaskDelegate>


/** The Base Service URL */
@property (nonatomic, strong) NSString *serviceBaseURL;

/** The Base Service URL */
@property (nonatomic, strong) NSCondition *waitForRegisterFinishedCondition;

/** The Base Service URL */
@property (nonatomic, strong) NSString *tryToRegisterToAPIKey;

/** The Base Service URL */
@property (nonatomic, strong) NSString *registerAPIKey;


/** The Base Service URL */
@property (nonatomic, strong) NSString *registerBundleID;

/** The URL session. */
@property (nonatomic, readonly, strong) NSDictionary *settingDict;

/** The URL session. */
@property (nonatomic, readonly, strong) NSURLSession *session;

/** Server certificate. */
@property (nonatomic, readonly, strong) PLVServerCertificate *serverCertificate;

/** Server trust validator. */
@property (nonatomic, readonly, strong) PLVServerTrustValidator *serverTrustValidator;

@property (nonatomic,strong) NSDateFormatter *dateFormatter;

/** Stops the receiver invalidating all sessions. */
- (void)stop;

/** Creates HTTP POST request with the specified path, parameters, and authentication token. */
- (NSMutableURLRequest *)requestWithPath:(NSString *)path
                              parameters:(NSDictionary *)parameters
                     authenticationToken:(NSString *)authenticationToken;

/** Creates a task with the specified URL request and resumes it. The completion handler is called on the main queue. */
- (void)resumeTaskWithURLRequest:(NSURLRequest *)request
               completionHandler:(PLVInAppAPIClientCompletionHandler)completionHandler;

/** Returns escaped query string for the specified parameters dictionary. */
- (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary;

/** Returns URL-encoded string for the specified string. */
- (NSString *)URLEncodedStringFromString:(NSString *)string;

@end


@implementation PLVInAppAPIClient

- (instancetype)initWithQueue:(NSOperationQueue *)queue {
    
    self = [super init];
    if (self != nil) {
        _queue = queue;
        assert(_queue != nil);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        configuration.HTTPCookieStorage = nil;
        configuration.HTTPShouldSetCookies = NO;
        configuration.URLCredentialStorage = nil;
        configuration.URLCache = nil;
        configuration.timeoutIntervalForRequest = 10.0;
        configuration.TLSMinimumSupportedProtocol = kTLSProtocol12;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_queue];
        
        _serverCertificate = [[PLVServerCertificate alloc] init];
        _serverTrustValidator = [[PLVServerTrustValidator alloc] init];
        
        _waitForRegisterFinishedCondition = [[NSCondition alloc] init];
        
        PLVRequestPersistManager* puh = [PLVRequestPersistManager sharedInstance];
        
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_dateFormatter setTimeZone:timeZone];
        _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        
        
    }
    
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void) setSpecificBaseServiceURL:(NSString*)serviceURLString {
    
    self.serviceBaseURL = serviceURLString;
    
}
#pragma mark -

- (void)registerWithAPIKey:(NSString *)apiKey andBundleID:(NSString *)bundleID {
    
    self.registerAPIKey = apiKey;
    
    self.registerBundleID = bundleID;

    return;
}

- (void) userTokenForEmail:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSMutableDictionary* bodyParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:emailAddress,apiParameterKeyEmail,nil];
    
    NSString* requestIdentifierToken = [[PLVRequestPersistManager sharedInstance] addRequestToPersistStore:bodyParameters toEndpoint:PLVInAppClientAPIUsersEndPoint httpMethod:httpMethodePOST];
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:PLVInAppClientAPIUsersEndPoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodePOST;
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    request.HTTPBody = jsonData;
    
    // add HMAC
    
    [self addHmacForParameterDict:bodyParameters toRequest:request];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (![error.domain isEqualToString:NSURLErrorDomain] ) {
            [[PLVRequestPersistManager sharedInstance] removeRequestFromPersistStore:requestIdentifierToken];
        }
        
        if (completionHandler != Nil) {
            
            SDLog(@"Response from UserToken: %@",response);
            
            if (error == Nil) {
                error = [self parseResultForStatusAndError:response];
            }
            
            completionHandler(response, error);
        }
    }];
    
}

- (void) addPaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSMutableDictionary* bodyParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:userToken,apiParameterKeyUserToken,nil];
    
    if (useCase != Nil) {
        // add use case in case of ... otherwise it default value form BE will be used
        [bodyParameters setObject:useCase forKey:apiParameterKeyUseCase];
    }
    
    if(payInstrument != Nil) {

            NSDictionary* desc = [payInstrument piDictDescription];
            
            if (desc != Nil) {
                    [bodyParameters setObject:desc forKey:apiParameterKeyPI];
            }
    }
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIUsersAddPiEndPoint,userToken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodePOST;
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    request.HTTPBody = jsonData;
    
    // add HMAC
    
    [self addHmacForParameterDict:bodyParameters toRequest:request];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            
            SDLog(@"addPaymentInstruments %@",response);
            completionHandler(response, error);
            
        }
    }];
    
}

- (void) listPaymentInstrumentsForUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSMutableDictionary* bodyParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:userToken,apiParameterKeyUserToken,useCase, apiParameterKeyUseCase,nil];
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIListPisEndPoint,userToken,useCase]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodeGET;

    // add HMAC
    
    [self addHmacForParameterDict:bodyParameters toRequest:request];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            
            SDLog(@"Response from listPaymentInstrumentsForUserToken: %@",response);
            
            NSMutableDictionary* updatedResponseDict = [NSMutableDictionary dictionaryWithDictionary:response];
            
            if ([response objectForKey:apiParameterKeyAddPIs]) {
                
                NSArray* piArray = [response objectForKey:apiParameterKeyAddPIs];
                
                NSMutableArray* serializedPI = [NSMutableArray new];
                // serialize PI
                
                for (NSDictionary* piDict in piArray) {
                    
                    if ([piDict isKindOfClass:[NSDictionary class]]) {
                    
                        PLVPaymentInstrument* pi = [PLVPaymentInstrument serializeWithDict:piDict];
                        
                        if (pi != Nil) {
                            [serializedPI addObject:pi];
                        } else {
                            SDLog(@"Can't serialze PI from dict %@",piDict);
                        }
                    } else {
                        SDLog(@"Can't serialze PI from dict (not even dict at all) %@",piDict);
                    }
                    
                }
                
                // replace JSON Array with object Array
                [updatedResponseDict setObject:serializedPI forKey:apiParameterKeyAddPIs];
            }
        
            completionHandler((NSDictionary*)updatedResponseDict, error);
            
        }
    }];
}

- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrderSet forUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSMutableDictionary* bodyParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:useCase,apiParameterKeyUseCase,nil];

    if(piOrderSet != Nil && piOrderSet.count > 0) {
        
        NSMutableArray* orderedPIArray = [NSMutableArray new];
        
        [piOrderSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            
            PLVPaymentInstrument* baseType = (PLVPaymentInstrument*) obj;
            
            if ([baseType isKindOfClass:[PLVPaymentInstrument class]]) {
                
                OrderedDictionary* newOrderedItem = [OrderedDictionary new];
                
                NSString* piID = [NSString stringWithString:baseType.identifier];
                
                if (piID != Nil) {
                
                    [newOrderedItem setObject:piID forKey:@"identifier"];
                    [newOrderedItem setObject:[NSString stringWithFormat:@"%lu",(unsigned long)idx] forKey:@"sortIndex"];
                    [orderedPIArray addObject:newOrderedItem];
                }
            }

        }];
        
        [bodyParameters setObject:orderedPIArray forKey:apiParameterKeyAddPIs];
    }
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPISetPiListOrderEndPoint,userToken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodePOST;
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    [bodyParameters setObject:userToken forKey:apiParameterKeyUserToken];
    
    request.HTTPBody = jsonData;
    
    
    [self addHmacForParameterDict:bodyParameters toRequest:request];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            SDLog(@"setPaymentInstrumentsOrder: %@",response);
            completionHandler(response, error);
        }
    }];
    
}

- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(NSString*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSString* piID;
    
    if(payInstrument != Nil ) {
        
        if ([payInstrument isKindOfClass:[PLVPaymentInstrument class]]) {
            
            OrderedDictionary* newOrderedPi = [OrderedDictionary new];
            
            piID = [NSString stringWithString:payInstrument.identifier];
        }
    }
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:userToken,apiParameterKeyUserToken,piID,apiParameterPIIdentifier,nil];
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIUsersDisablePiEndPoint,userToken,piID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodeDELETE;

    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self addHmacForParameterDict:parameters toRequest:request];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            SDLog(@"disablePaymentInstruments: %@",response);
            completionHandler(response, error);
        }
    }];
}

- (void) removePaymentInstrument:(PLVPaymentInstrument*)payInstrument fromUseCase:(NSString*)useCase forUserToken:(NSString*)userToken  withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSString* piID;
    if(payInstrument != Nil ) {
        
        if ([payInstrument isKindOfClass:[PLVPaymentInstrument class]]) {
            
            piID = [NSString stringWithString:payInstrument.identifier];

        }
    }
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:userToken,apiParameterKeyUserToken,piID,apiParameterPIIdentifier,useCase,apiParameterKeyUseCase,nil];
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIRemovePiForUseCaseEndPoint,userToken,piID,useCase]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodeDELETE;

    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            SDLog(@"removePaymentInstrumentForUseCase: %@",response);
            completionHandler(response, error);
        }
    }];
    
}

#pragma mark -

- (void)stop {
    [self.session invalidateAndCancel];
}

- (NSURL*) getBaseServiceURL {
    
    if (self.serviceBaseURL != Nil) {
        return  [NSURL URLWithString:self.serviceBaseURL];
    }
    
    return [NSURL URLWithString:PLVInAppClientAPIHost];
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path
                              parameters:(NSDictionary *)parameters
                     authenticationToken:(NSString *)authenticationToken {
    
    assert(path.length > 0);
    if (path.length == 0) {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:self.serviceBaseURL];
    URL = [URL URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self queryStringFromDictionary:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if (authenticationToken.length > 0) {
        [request setValue:[NSString stringWithFormat:@"Payleven %@", authenticationToken]
       forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

- (void)resumeTaskWithURLRequest:(NSURLRequest *)request
               completionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler {
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            
            // Connection Error case
            
            SDLog(@"Error sending API request: %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionHandler(Nil, error);
            });
            
        }
        
        NSDictionary *responseDict = nil;
        
        NSError *JSONError;
        
        responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if (JSONError != noErr) {
            
            SDLog(@"Error creating dictionary from JSON data: %@", JSONError);
            
            SDLog(@"String sent from server %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionHandler(Nil, JSONError);
            });
            
            return;
        } else {
            
            NSHTTPURLResponse* httpURLResponse = (NSHTTPURLResponse*)response;
            
            //TODO CHeck for valid NSHTTPURLResponse
            
            SDLog(@"statusCode %lu: %@",(long)httpURLResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpURLResponse.statusCode]);
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
                
            completionHandler(responseDict, error);
        });
            

    }];
    
    [task resume];
}

- (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary {
    if (dictionary.count == 0) {
        return nil;
    }
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:dictionary.count];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@",
                              [self URLEncodedStringFromString:key], [self URLEncodedStringFromString:obj]]];
        }
    }];
    
    return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)URLEncodedStringFromString:(NSString *)string {
    CFStringRef result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                 (__bridge CFStringRef)string,
                                                                 NULL,
                                                                 CFSTR(":/?#[]@!$&'()*+,;="),
                                                                 kCFStringEncodingUTF8);
    
    return (__bridge_transfer NSString *)result;
}


#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
        didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
        completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        BOOL isValid = [self.serverTrustValidator validateServerTrust:challenge.protectionSpace.serverTrust
                                         withPublicKeyFromCertificate:self.serverCertificate.data];
        if (isValid) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
    }
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
        task:(NSURLSessionTask *)task
        didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
        completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    
//    if (challenge.previousFailureCount == 0) {
//        NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
//        if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] &&
//            [protectionSpace.host isEqualToString:PLVInAppAPIClientRegisterHost]) {
//            disposition = NSURLSessionAuthChallengeUseCredential;
////            credential = [NSURLCredential credentialWithUser:PLVAPIClientStagingLoginUsername
////                                                    password:PLVAPIClientStagingLoginPassword
////                                                 persistence:NSURLCredentialPersistenceNone];
//        }
//    }
    
    completionHandler(disposition, credential);
}



-(void)addHmacForParameterDict:(NSMutableDictionary*)parameters toRequest:(NSMutableURLRequest*)request {
    
    //1. create timestamp string

    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];

    //2. add timestamp to params
    [parameters setObject:timestamp forKey:apiHeaderKeyXHmacTimeStamp];
    [parameters setObject:self.registerBundleID forKey:apiHeaderKeyXBundleID];
    [parameters setObject:PLVInAppSDKVersion forKey:apiHeaderKeyXSDKVersion];
    
    [request setValue:timestamp forHTTPHeaderField:apiHeaderKeyXHmacTimeStamp];
    [request setValue:self.registerBundleID forHTTPHeaderField:apiHeaderKeyXBundleID];
    [request setValue:PLVInAppSDKVersion forHTTPHeaderField:apiHeaderKeyXSDKVersion];

    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:apiHeaderKeyXOSVersion];
    [request setValue:[[UIDevice currentDevice] platformString] forHTTPHeaderField:apiHeaderKeyXDeviceType];
    
    [request setValue:@"baseAuthToken" forHTTPHeaderField:apiHeaderKeyXAuthType];
    

    //3. sort params alphabetically & generate query string
    NSString* query = [self generateHmacQueryString:parameters];
    
    //4. generate hash
    const char *cKey = [self.registerAPIKey cStringUsingEncoding:NSUTF8StringEncoding];

    const char *cData = [query cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [[HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    HMAC = nil;
    
    [request setValue:hash forHTTPHeaderField:apiHeaderKeyXHmac];

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
                        [pairs addObject:[NSString stringWithFormat:@"%@[%lu][%@]=%@", key,i, subKey, [subValueDict objectForKey:subKey]]];
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


- (NSError*) parseResultForStatusAndError:(NSDictionary*)dict {
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        
        if ([dict objectForKey:plvInAppSDKResponseStatusKey]) {
            
            if ([[dict objectForKey:plvInAppSDKResponseStatusKey] isEqualToString:plvInAppSDKStatusOK]) {
                return Nil;
            } else if ([[dict objectForKey:plvInAppSDKResponseStatusKey] isEqualToString:plvInAppSDKStatusKO]) {
                
                if ([dict objectForKey:plvInAppSDKResponseDescriptionKey] && [dict objectForKey:plvInAppSDKResponseCodeKey]) {
                    return [NSError errorWithDomain:PLVAPIBackEndErrorDomain code:[[dict objectForKey:plvInAppSDKResponseCodeKey] intValue] userInfo:[NSDictionary dictionaryWithObject:[dict objectForKey:plvInAppSDKResponseDescriptionKey] forKey:NSLocalizedDescriptionKey]];
                }
            }
        }
    }

    return [NSError errorWithDomain:PLVAPIBackEndErrorDomain code:ERROR_INVALID_BACKEND_RESPONSE_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_INVALID_BACKEND_RESPONSE_MESSAGE forKey:NSLocalizedDescriptionKey]];
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


