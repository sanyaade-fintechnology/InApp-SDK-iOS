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
#import "PLVInAppClientTypes.h"
#import "OrderedDictionary.h"
#import "PLVRequestPersistManager.h"
#import <CommonCrypto/CommonCrypto.h>
#import "DevicePlatform.h"
#import "PLVReachability.h"

#define apiParameterKeyEmail @"email"
#define apiParameterKeyUserToken @"userToken"
#define apiParameterPIIdentifier @"identifier"
#define apiParameterKeyAddPIs @"paymentInstruments"
#define apiParameterKeyPI @"paymentInstrument"
#define apiParameterKeyUseCase @"useCase"


#define apiHeaderKeyXHmacTimeStamp @"X-Hmac-Timestamp"
#define apiHeaderKeyXHmac @"X-HMAC"
#define apiHeaderKeyXBundleID @"X-ApplicationID"
#define apiHeaderKeyXBodyHash @"X-Body-Hash"
#define apiHeaderKeyXSDKVersion @"X-Sdk-Version"
#define apiHeaderKeyXOSVersion @"X-OS-Version"
#define apiHeaderKeyXDeviceType @"X-Device-Model"
#define apiHeaderKeyXAuthType @"X-Authorization"


#define httpMethodePOST @"POST"
#define httpMethodeGET @"GET"
#define httpMethodeDELETE @"DELETE"


#define PLVInAppClientAPIUsersEndPoint @"/users"
#define PLVInAppClientAPIUsersAddPiEndPoint @"/%@/payment-instruments"
#define PLVInAppClientAPIListPisEndPoint @"%@/%@/payment-instruments/use-case/%@"
#define PLVInAppClientAPISetPiListOrderEndPoint @"/%@/payment-instruments/use-case/%@/sort-index"
#define PLVInAppClientAPIUsersDisablePiEndPoint @"/%@/payment-instruments/%@"
#define PLVInAppClientAPIRemovePiForUseCaseEndPoint @"/%@/payment-instruments/%@/use-case/%@"




#define useLocalEndpoint 0
#define useOtherEndpoint 0
#define usemacMiniEndpoint 0
#define usePHPStagingEndpoint 0
#define useJBEStagingEndpoint 1




#if useLocalEndpoint
/** locahost endpoint. */

static NSString * const PLVInAppClientAPIHost = @"localhost";

static NSString * const PLVInAppClientAPIServiceURL = @"http://localhost/staging/api";

/** Staging username for Basic auth during login.*/
static NSString * const PLVAPIClientStagingLoginUsername = @"without";

/** Staging password for Basic auth during login. */
static NSString * const PLVAPIClientStagingLoginPassword = @"nopassword";


#elif usemacMiniEndpoint

/** macMini in office endpoint. */

static NSString * const PLVInAppClientAPIHost = @"http://10.15.100.130:8888";

static NSString * const PLVInAppClientAPIServiceURL = @"http://10.15.100.130:8888/staging/api";

/** Staging username for Basic auth during login.*/
static NSString * const PLVAPIClientStagingLoginUsername = @"without";

/** Staging password for Basic auth during login. */
static NSString * const PLVAPIClientStagingLoginPassword = @"nopassword";

#elif usePHPStagingEndpoint

static NSString * const PLVInAppClientAPIHost = @"mockbe.payleven.de";

static NSString * const PLVInAppClientAPIServiceURL = @"https://mockbe.payleven.de/api";

/** Staging username for Basic auth during login.*/
static NSString * const PLVAPIClientStagingLoginUsername = @"mockbe";

/** Staging password for Basic auth during login. */
static NSString * const PLVAPIClientStagingLoginPassword = @"aekoc9biep8L";

#elif useOtherEndpoint

static NSString * const PLVInAppClientAPIHost = @"10.15.100.77";

static NSString * const PLVInAppClientAPIServiceURL = @"http://10.15.100.77/staging/api";

/** Staging username for Basic auth during login.*/
static NSString * const PLVAPIClientStagingLoginUsername = @"mockbe";

/** Staging password for Basic auth during login. */
static NSString * const PLVAPIClientStagingLoginPassword = @"aekoc9biep8L";

#elif useJBEStagingEndpoint

/** staging endpoint */

static NSString * const PLVInAppClientAPIHost = @"backend-staging.payleven.de";
//apiproxy-staging.payleven.de
static NSString * const PLVInAppClientAPIServiceURL = @"https://backend-staging.payleven.de/api/v1/payers";

/** Staging username for Basic auth during login.*/
//static NSString * const PLVAPIClientStagingLoginUsername = @"hal9000";
static NSString * const PLVAPIClientStagingLoginUsername = @"payerinappuser";


/** Staging password for Basic auth during login. */
//static NSString * const PLVAPIClientStagingLoginPassword = @"!$0penthep0dbayd00rs$!";
static NSString * const PLVAPIClientStagingLoginPassword = @"4BKgvnHXTGR5wrJpnSpNqxwS";

#endif


static NSString * const PLVInAppSDKVersion = @"1.0";
NSInteger alphabeticKeySort(id string1, id string2, void *reverse);

@interface PLVInAppAPIClient () <NSURLSessionTaskDelegate>


/** The Base Service URL */
@property (nonatomic, strong) NSString *serviceBaseURL;

/** The Base Service URL */
@property (nonatomic, strong) NSCondition *waitForRegisterFinishedCondition;

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

@property (nonatomic, strong) PLVRequestPersistManager* requestPersistmanager;

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
        
        _requestPersistmanager = [PLVRequestPersistManager sharedInstance];
        
        [_requestPersistmanager registerAPIClient:self];
        
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_dateFormatter setTimeZone:timeZone];
        _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kPLVReachabilityChangedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
}

- (void)reachabilityChanged:(NSNotification*) notif {
    
    PLVReachability* curReach = [notif object];
    if ([curReach isKindOfClass:[PLVReachability class]]) {
        
        if (curReach.currentReachabilityStatus != NotReachable) {
            
            [self.requestPersistmanager fireImmediately];
        }
    }

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
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:PLVInAppClientAPIUsersEndPoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodePOST;
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    NSString* bodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
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

        // Hook around to expose method 'piDictDescription' to customers
    
        SEL selector = NSSelectorFromString(@"piDictDescription");
        IMP imp = [payInstrument methodForSelector:selector];
        NSDictionary* (*func)(id, SEL) = (void *)imp;
        NSDictionary* desc  = func(payInstrument, selector);

        if (desc != Nil) {
            [bodyParameters setObject:desc forKey:apiParameterKeyPI];
        }
    }
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIUsersAddPiEndPoint,userToken]];
    
    __block NSString* requestIdentifierToken = [[PLVRequestPersistManager sharedInstance] addRequestToPersistStore:bodyParameters toEndpoint:[NSString stringWithFormat:PLVInAppClientAPIUsersAddPiEndPoint,userToken] httpMethod:httpMethodePOST];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodePOST;
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    NSString* bodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];

    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (![error.domain isEqualToString:NSURLErrorDomain] ) {
            
            [[PLVRequestPersistManager sharedInstance] removeRequestFromPersistStore:requestIdentifierToken];
            
            [[PLVRequestPersistManager sharedInstance] fireImmediately];
            
            if (completionHandler != Nil) {
                SDLog(@"addPaymentInstruments %@",response);
                completionHandler(response, error);
            }
        }
        
    }];
    
}


- (void) startRequestWithBody:(NSDictionary*)bodyParameters addEndpoint:(NSString*)endpoint andHTTPMethod:(NSString*)httpMethod andRequestIdentifier:(NSString*)requestIdentifierToken {
    
    SDLog(@"Retray Request with Identifier: %@",requestIdentifierToken);
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:endpoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethod;
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    NSString* bodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];

    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (![error.domain isEqualToString:NSURLErrorDomain] ) {
            [[PLVRequestPersistManager sharedInstance] removeRequestFromPersistStore:requestIdentifierToken];
        }
        
    }];
}

- (void) listPaymentInstrumentsForUserToken:(NSString*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:PLVInAppClientAPIListPisEndPoint,[self getBaseServiceURL],userToken,useCase]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    request.HTTPMethod = httpMethodeGET;

    // add HMAC
    
    NSString* bodyString = @"";
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];
    
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
                    
                        PLVPaymentInstrument* pi = [PLVPaymentInstrument performSelector:NSSelectorFromString(@"serializeWithDict:") withObject:piDict];
                        
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
        
            if (completionHandler != Nil) {
                completionHandler((NSDictionary*)updatedResponseDict, error);
            }
            
            if (error == Nil ) {
                [[PLVRequestPersistManager sharedInstance] fireImmediately];
            } else {
                if (![error.domain isEqualToString:NSURLErrorDomain] ) {
                    [[PLVRequestPersistManager sharedInstance] fireImmediately];
                }
            }
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
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPISetPiListOrderEndPoint,userToken,useCase]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    request.HTTPMethod = httpMethodePOST;
    
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    NSString* bodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];

    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            SDLog(@"setPaymentInstrumentsOrder: %@",response);
            completionHandler(response, error);
        }
        
        if (error == Nil ) {
            [[PLVRequestPersistManager sharedInstance] fireImmediately];
        } else {
            if (![error.domain isEqualToString:NSURLErrorDomain] ) {
                [[PLVRequestPersistManager sharedInstance] fireImmediately];
            }
        }
    }];
    
}

- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(NSString*)userToken withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSString* piID;
    
    if(payInstrument != Nil ) {
        if ([payInstrument isKindOfClass:[PLVPaymentInstrument class]]) {
            piID = [NSString stringWithString:payInstrument.identifier];
        }
    }
    
    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIUsersDisablePiEndPoint,userToken,piID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodeDELETE;

    NSString* bodyString = @"";
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];
    
    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            SDLog(@"disablePaymentInstruments: %@",response);
            completionHandler(response, error);
        }
        
        if (error == Nil ) {
            [[PLVRequestPersistManager sharedInstance] fireImmediately];
        } else {
            if (![error.domain isEqualToString:NSURLErrorDomain] ) {
                [[PLVRequestPersistManager sharedInstance] fireImmediately];
            }
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

    NSURL *URL = [self getBaseServiceURL];
    
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:PLVInAppClientAPIRemovePiForUseCaseEndPoint,userToken,piID,useCase]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = httpMethodeDELETE;
    
    NSString* bodyString = @"";
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addHmacWithBodyContent:bodyString toRequest:request];

    [self resumeTaskWithURLRequest:request completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (completionHandler != Nil) {
            SDLog(@"removePaymentInstrumentForUseCase: %@",response);
            completionHandler(response, error);
        }
        
        if (error == Nil ) {
            [[PLVRequestPersistManager sharedInstance] fireImmediately];
        } else {
            if (![error.domain isEqualToString:NSURLErrorDomain] ) {
                [[PLVRequestPersistManager sharedInstance] fireImmediately];
            }
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
    
    return [NSURL URLWithString:PLVInAppClientAPIServiceURL];
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
    
    SDLog(@"Start Request to url: %@ and Body: %@",request.URL.absoluteString,[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] );
    
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse* httpURLResponse = (NSHTTPURLResponse*)response;
        
        //TODO Check for valid NSHTTPURLResponse
        
        SDLog(@"url: %@\n statusCode %lu: %@",httpURLResponse.URL.absoluteString,(long)httpURLResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpURLResponse.statusCode]);
        
        if (error != nil) {
            
            // Connection Error case
            
            SDLog(@"Error sending API request: %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionHandler(Nil, error);
            });
            
            return;
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
    
    if (challenge.previousFailureCount == 0) {
        NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
        if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] &&
            [protectionSpace.host isEqualToString:PLVInAppClientAPIHost]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialWithUser:PLVAPIClientStagingLoginUsername
                                                    password:PLVAPIClientStagingLoginPassword
                                                 persistence:NSURLCredentialPersistenceNone];
        }
    }
    
    completionHandler(disposition, credential);
}



-(void)addHmacWithBodyContent:(NSString*)bodyContent toRequest:(NSMutableURLRequest*)request {

    //1. update headers
    
    NSString* timeStamp = [self getTimeStampAsString];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:timeStamp forHTTPHeaderField:apiHeaderKeyXHmacTimeStamp];
    [request setValue:self.registerBundleID forHTTPHeaderField:apiHeaderKeyXBundleID];
    [request setValue:PLVInAppSDKVersion forHTTPHeaderField:apiHeaderKeyXSDKVersion];

    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:apiHeaderKeyXOSVersion];
    [request setValue:[DevicePlatform platformString] forHTTPHeaderField:apiHeaderKeyXDeviceType];
    
    if (bodyContent == Nil) {
        
        bodyContent = @"";
    }
    
    NSString* bodyHash = [self sha256:bodyContent];
    
    [request setValue:bodyHash forHTTPHeaderField:apiHeaderKeyXBodyHash];
    
    //2. sort params to generate query string
    NSString* query = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",request.HTTPMethod,request.URL.absoluteString,self.registerBundleID,bodyHash,timeStamp];
    
    //3. generate hash
    const char *cKey = [self.registerAPIKey cStringUsingEncoding:NSUTF8StringEncoding];

    const char *cData = [query cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [[HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    hash = [hash stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    HMAC = nil;
    
    [request setValue:hash forHTTPHeaderField:apiHeaderKeyXHmac];

}

- (NSString*) getTimeStampAsString {
    
    //1. create timestamp string
    
    return [self.dateFormatter stringFromDate:[NSDate date]];
}

- (double) getTimeStamp {
    
    //1. create timestamp string
    
    return [[NSDate date] timeIntervalSinceReferenceDate];
    
}



-(NSString*) sha256:(NSString *)inputString{
    const char *s=[inputString cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (unsigned int) keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    hash = [hash stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return hash;
}


- (NSError*) parseResultForStatusAndError:(NSDictionary*)dict {
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        
        if ([dict objectForKey:plvInAppSDKResponseStatusKey]) {
            
            id statusResult = [dict objectForKey:plvInAppSDKResponseStatusKey];
            
            if ([statusResult isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary* resultDict = (NSDictionary*) statusResult;
                
                if ([[[resultDict objectForKey:plvInAppSDKResultKey] uppercaseString] isEqualToString:plvInAppSDKStatusOK]) {
                    return Nil;
                } else if ([[[resultDict objectForKey:plvInAppSDKResponseStatusKey] uppercaseString] isEqualToString:plvInAppSDKStatusKO]) {
                    
                    if ([resultDict objectForKey:plvInAppSDKResponseMessageKey] && [resultDict objectForKey:plvInAppSDKResponseCodeKey]) {
                        
                        return [NSError errorWithDomain:PLVAPIBackEndErrorDomain code:[[resultDict objectForKey:plvInAppSDKResponseCodeKey] intValue] userInfo:[NSDictionary dictionaryWithObject:[resultDict objectForKey:plvInAppSDKResponseMessageKey] forKey:NSLocalizedDescriptionKey]];
                    }
                }
                
            } else if ([statusResult isKindOfClass:[NSString class]]) {
                
                // legacy for old MockBE
                
                if ([[dict objectForKey:plvInAppSDKResponseStatusKey] isEqualToString:plvInAppSDKStatusOK]) {
                    return Nil;
                } else if ([[dict objectForKey:plvInAppSDKResponseStatusKey] isEqualToString:plvInAppSDKStatusKO]) {
                    
                    if ([dict objectForKey:plvInAppSDKResponseDescriptionKey] && [dict objectForKey:plvInAppSDKResponseCodeKey]) {
                        return [NSError errorWithDomain:PLVAPIBackEndErrorDomain code:[[dict objectForKey:plvInAppSDKResponseCodeKey] intValue] userInfo:[NSDictionary dictionaryWithObject:[dict objectForKey:plvInAppSDKResponseDescriptionKey] forKey:NSLocalizedDescriptionKey]];
                    }
                }
            }
        
        }
    }

    return [NSError errorWithDomain:PLVAPIBackEndErrorDomain code:ERROR_INVALID_BACKEND_RESPONSE_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_INVALID_BACKEND_RESPONSE_MESSAGE forKey:NSLocalizedDescriptionKey]];
}


@end


