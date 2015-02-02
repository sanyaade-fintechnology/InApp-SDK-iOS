//
//  PLVEventTransformer.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 06/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVEventTransformer.h"

#import "PLVEvent.h"


@interface PLVEventTransformer ()

/** Date formatter. */
@property(nonatomic, readonly, strong) NSDateFormatter *dateFormatter;

/** Amount number formatter. */
@property(nonatomic, readonly, strong) NSNumberFormatter *numberFormatter;

/** Performs the actual transformation from PLVEvent to NSDictionary. */
- (NSDictionary *)dictionaryForEvent:(PLVEvent *)event;

/** Returns string for the event type. */
- (NSString *)stringForEventType:(PLVEventType)eventType;

@end


@implementation PLVEventTransformer

+ (BOOL)allowsReverseTransformation {
    return NO;
}

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[PLVEvent class]]) {
        return [self dictionaryForEvent:value];
    } else {
        return nil;
    }
}


#pragma mark - Private

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss";
    });
    
    return formatter;
}

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    return formatter;
}

- (NSDictionary *)dictionaryForEvent:(PLVEvent *)event {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Timestamp. ISO 8601 date string in UTC time zone. Example: 2012-06-27T01:21:00.
    if (event.date != nil) {
        dict[PLVEventTransformerTimestamp] = [self.dateFormatter stringFromDate:event.date];
    }
    
    // Event.
    dict[PLVEventTransformerEvent] = [self stringForEventType:event.eventType];
    
    // Event Data.
    if (event.eventData != nil) {
        dict[PLVEventTransformerData] = event.eventData;
    }
    
    if (event.responseTime != Nil) {
        dict[PLVEventTransformerResponseTime] = event.responseTime;
    }
    
    if (event.userToken != nil) {
        dict[PLVEventTransformerUserToken] = event.userToken;
    }
    
    return [dict copy];
}

- (NSString *)stringForEventType:(PLVEventType)eventType {
    static NSDictionary *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
                @(PLVEventTypeInitInAPPClient):                         @"InitInAPPClient",
                @(PLVEventTypeCloseInAPPClient):                        @"CloseInAPPClient",
                @(PLVEventTypeCreateUserTokenSuccess):                  @"CreateUserTokenSuccess",
                @(PLVEventTypeCreateUserTokenFail):                     @"CreateUserTokenFail",
                @(PLVEventTypeAddPaymentInstrumentSuccess):             @"AddPaymentInstrumentSuccess",
                @(PLVEventTypeAddPaymentInstrumentFail):                @"AddPaymentInstrumentFail",
                @(PLVEventTypeDisablePaymentInstrumentSuccess):         @"DisablePaymentInstrumentSuccess",
                @(PLVEventTypeDisablePaymentInstrumentFail):            @"DisablePaymentInstrumentFail",
                @(PLVEventTypeRemovePaymentInstrumentSuccess):          @"RemovePaymentInstrumentSuccess",
                @(PLVEventTypeRemovePaymentInstrumentFail):             @"RemovePaymentInstrumentFail",
                @(PLVEventTypeSetPaymentInstrumentsOrderSuccess):       @"SetPaymentInstrumentsOrderSuccess",
                @(PLVEventTypeSetPaymentInstrumentsOrderFail):          @"SetPaymentInstrumentsOrderFail",
                @(PLVEventTypeListPaymentInstrumentsSuccess):           @"ListPaymentInstrumentsSuccess",
                @(PLVEventTypeListPaymentInstrumentsFail):              @"ListPaymentInstrumentsFail"
                };
    });
    
    return map[@(eventType)];
}

@end


NSString * const PLVEventTransformerTimestamp = @"timestamp";
NSString * const PLVEventTransformerEvent = @"event";
NSString * const PLVEventTransformerData = @"data";
NSString * const PLVEventTransformerTransactionID = @"transactionId";
NSString * const PLVEventTransformerPaymentID = @"paymentId";
NSString * const PLVEventTransformerAmount = @"amount";
NSString * const PLVEventTransformerCurrency = @"currency";
NSString * const PLVEventTransformerCountry = @"paymentCountry";
NSString * const PLVEventTransformerDeviceIdentifier = @"deviceId";
NSString * const PLVEventTransformerResponseTime = @"responseTime";
NSString * const PLVEventTransformerUserToken = @"userToken";
