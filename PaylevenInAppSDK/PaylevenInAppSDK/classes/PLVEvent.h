//
//  PLVEvent.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 06/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/** Event type constans. */
typedef NS_ENUM(NSInteger, PLVEventType) {
    PLVEventTypeInitInAPPClient,        /**< Login. */
    PLVEventTypeCloseInAPPClient,
    PLVEventTypeCreateUserTokenSuccess,
    PLVEventTypeCreateUserTokenFail,
    PLVEventTypeAddPaymentInstrumentSuccess,
    PLVEventTypeAddPaymentInstrumentFail,
    PLVEventTypeDisablePaymentInstrumentSuccess,
    PLVEventTypeDisablePaymentInstrumentFail,
    PLVEventTypeRemovePaymentInstrumentSuccess,
    PLVEventTypeRemovePaymentInstrumentFail,
    PLVEventTypeSetPaymentInstrumentsOrderSuccess,
    PLVEventTypeSetPaymentInstrumentsOrderFail,
    PLVEventTypeListPaymentInstrumentsSuccess,
    PLVEventTypeListPaymentInstrumentsFail
};

/** PLVEvent represents an event to be logged. */
@interface PLVEvent : NSObject

/** Event timestamp. */
@property(nonatomic, readonly, copy) NSDate *date;

/** response time. */
@property(nonatomic, readonly, copy) NSString *responseTime;

/** Event type. */
@property(nonatomic, readonly, assign) PLVEventType eventType;

/** Event data. */
@property(nonatomic, readonly) NSMutableDictionary* eventData;

/** User token. */
@property(nonatomic, readonly, copy) NSString *userToken;

///** Merchant identifier. */
//@property(nonatomic, readonly, copy) NSString *merchantIdentifier;
//
///** Transaction identifier. */
//@property(nonatomic, readonly, copy) NSString *transactionIdentifier;
//
///** Payment identifier. */
//@property(nonatomic, readonly, copy) NSString *paymentIdentifier;
//
///** Amount. */
//@property(nonatomic, readonly, copy) NSDecimalNumber *amount;
//
///** ISO 4217 currency code. Example: EUR. */
//@property(nonatomic, readonly, copy) NSString *currency;
//
///** ISO 3166-1 alpha-2 country code. */
//@property(nonatomic, readonly, copy) NSString *country;
//
///** Payment device identifier. */
//@property(nonatomic, readonly, copy) NSString *deviceIdentifier;
//
///** Dictionary with additional parameters. */
//@property(nonatomic, readonly, strong) NSDictionary *userInfo;

/**
 * Returns the newly created event with the date set to the current date and time.
 *
 * @param parameters
 * Parameters dictionary. The keys of the dictionary are property names and the values are the corresponding property
 * values. The parameters @c date and @c eventType are ignored.
 *
 * @param eventType
 * The event type.
 */
+ (instancetype)eventForNowWithType:(PLVEventType)eventType parameters:(NSDictionary *)parameters;

/**
 * Initializes the receiver with parameters dictionary.
 *
 * @param parameters
 * Parameters dictionary. The keys of the dictionary are property names and the values are the corresponding property
 * values.
 *
 * @warning
 * The parameters @c date and @c eventType must be present.
 */
//- (instancetype)initWithDictionary:(NSDictionary *)parameters;

@end
