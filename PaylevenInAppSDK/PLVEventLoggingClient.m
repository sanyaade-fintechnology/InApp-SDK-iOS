//
//  PLVEventLoggingClient.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 11/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVEventLoggingClient.h"

#import "PLVEvent.h"
#import "PLVEventTransformer.h"
#import "PLVHTTPUserAgent.h"
#import "PLVInAppSDKConstants.h"

/** Event logging username. */
static NSString * const PLVEventLoggingUsername = @"logfrontend";

/** Event logging password. */
static NSString * const PLVEventLoggingPassword = @"cvzdtgyMMFuZT2xYy2LoYEcK";

//static NSString * const PLVEventLoggingEndpoint = @"http://10.15.100.130:8888/staging/api/logs";

/** Event logging endpoint. */
static NSString * const PLVEventLoggingEndpoint = @"http://localhost/staging/api/logs";

@interface PLVEventLoggingClient ()

/** URL session. */
@property(nonatomic, readonly, strong) NSURLSession *session;

/** Returns event-send request with the specified request body. */
- (NSMutableURLRequest *)requestWithBody:(NSData *)body;

/** Returns JSON data for the specified PLVEvent objects. */
- (NSData *)JSONDataWithEvents:(NSArray *)events;

/** Returns a dictionary with an array of dictionaries from the specified PLVEvent objects. */
- (NSDictionary *)eventsDictionaryFromEvents:(NSArray *)events;

@end


@implementation PLVEventLoggingClient

- (instancetype)initWithQueue:(NSOperationQueue *)queue andDelegate:(id <NSURLSessionDelegate>)delegate {
    self = [super init];
    if (self != nil) {
        _queue = queue;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        configuration.HTTPCookieStorage = nil;
        configuration.HTTPShouldSetCookies = NO;
        configuration.URLCredentialStorage = nil;
        configuration.URLCache = nil;
        configuration.TLSMinimumSupportedProtocol = kTLSProtocol12;
        configuration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/json",
                                                @"User-Agent": [PLVHTTPUserAgent userAgentString]};
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:delegate
                                            delegateQueue:_queue];
    }
    
    return self;
}


#pragma mark -

- (void)sendEvents:(NSArray *)events completionHandler:(void (^)(BOOL success))completionHandler {
    NSData *JSONData = [self JSONDataWithEvents:events];
    NSURLRequest *request = [self requestWithBody:JSONData];
    NSURLSessionDataTask *task
    = [self.session dataTaskWithRequest:request completionHandler:
       ^(NSData *data, NSURLResponse *response, NSError *error) {
           BOOL success = NO;
           if (error == nil) {
               NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
               if (HTTPResponse.statusCode / 100 == 2) {
                   success = YES;
               }
           }
           if (completionHandler != nil) {
               completionHandler(success);
           }
       }];
    [task resume];
}


#pragma mark - Private

- (NSURLRequest *)requestWithBody:(NSData *)body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PLVEventLoggingEndpoint]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    
    return request;
}

- (NSData *)JSONDataWithEvents:(NSArray *)events {
    NSDictionary *eventsDict = [self eventsDictionaryFromEvents:events];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:eventsDict options:0 error:&error];
    if (data == nil) {
        NSLog(@"Error creating JSON data: %@", error);
    }
    
    return data;
}

- (NSDictionary *)eventsDictionaryFromEvents:(NSArray *)events; {
    NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:events.count];
    PLVEventTransformer *transformer = [[PLVEventTransformer alloc] init];
    for (PLVEvent *event in events) {
        NSDictionary *eventDict = [transformer transformedValue:event];
        if (eventDict != nil) {
            [dictionaries addObject:eventDict];
        }
    }
    
    return @{@"events": dictionaries};
}

@end
