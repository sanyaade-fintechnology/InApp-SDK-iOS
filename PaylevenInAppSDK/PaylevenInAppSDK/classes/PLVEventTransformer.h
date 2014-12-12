//
//  PLVEventTransformer.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 06/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/** A class that transforms PLVEvent objects into NSDictionary objects that can be used while sending event logs. */
@interface PLVEventTransformer : NSValueTransformer

@end

/** timestamp. */
extern NSString * const PLVEventTransformerTimestamp;

/** event. */
extern NSString * const PLVEventTransformerEvent;

/** merchantId. */
extern NSString * const PLVEventTransformerMerchantID;

/** transactionId. */
extern NSString * const PLVEventTransformerTransactionID;

/** paymentId. */
extern NSString * const PLVEventTransformerPaymentID;

/** amount. */
extern NSString * const PLVEventTransformerAmount;

/** currency. */
extern NSString * const PLVEventTransformerCurrency;

/** paymentCountry. */
extern NSString * const PLVEventTransformerCountry;

/** deviceId. */
extern NSString * const PLVEventTransformerDeviceIdentifier;

/** data. */
extern NSString * const PLVEventTransformerData;
