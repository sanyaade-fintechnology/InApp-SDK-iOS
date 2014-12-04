//
//  PLVEvent.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 06/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVEvent.h"


@implementation PLVEvent

+ (instancetype)eventForNowWithType:(PLVEventType)eventType parameters:(NSDictionary *)parameters {
    NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    newParameters[@"timestamp"] = [NSDate date];
    newParameters[@"event"] = @(eventType);
    
    return [[[self class] alloc] initWithDictionary:newParameters];
}

- (instancetype)initWithDictionary:(NSDictionary *)parameters {
    if (parameters[@"event"] == nil) {
        @throw [NSException exceptionWithName:@"PLVEvent BadInitCall"
                                       reason:@"Parameters eventType must be present"
                                     userInfo:nil];
        return nil;
    }

    _eventData = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    self = [super init];
    if (self != nil) {
        assert(parameters[@"event"] != nil);
        _eventType = [parameters[@"event"] integerValue];
    }
    
    if (parameters[@"timestamp"] == nil) {
        _date = [NSDate date];
    } else {
        _date = parameters[@"timestamp"];
        [_eventData removeObjectForKey:@"timestamp"];
        
    }
    
    [_eventData removeObjectForKey:@"event"];
    
    return self;
}



@end
