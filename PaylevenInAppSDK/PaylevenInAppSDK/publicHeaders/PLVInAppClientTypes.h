//
//  PLVInAppClientTypes.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

#define     PLVPITypeUnknown    @"PLVPITypeUnknown"
#define     PLVPITypeCC         @"CC"
#define     PLVPITypeDD         @"DD"
#define     PLVPITypeSEPA       @"SEPA"
#define     PLVPITypePAYPAL     @"PAYPAL"


/**
 *  PLVPaymentInstrument    Base class of PLVPaymentInstrument
 *
 *  @property sortIndex     index the payment instrument in a certain usecase (readonly)
 *
 *  @property identifier    identifier of this payment instrument (readonly
 *
 */
@interface PLVPaymentInstrument : NSObject

@property (strong) NSString* type;
@property (strong, readonly) NSString* sortIndex;
@property (strong, readonly) NSString* identifier;

@end

/**
 *  PLVPayInstrumentCC      CrediCard PaymentInstrument
 *
 *  @property pan           pan of the Creditcard
 *
 *  @property cardBrand     cardbrand
 *
 *  @property expiryMonth   expiryMonth
 *
 *  @property expiryYear    expiryYear
 *
 *  @property cvv           Card verification value
 *
 */

@interface PLVPayInstrumentCC : PLVPaymentInstrument

@property (strong) NSString* pan;
@property (readonly,nonatomic) NSString* cardBrand;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;
@property (strong) NSString* cvv;

@end

/**
 *  PLVPayInstrumentDD      Debit PaymentInstrument
 *
 *  @property accountNumber accountNumber for this debit account
 *
 *  @property routingNumber routingNumber for this debit account
 *
 */

@interface PLVPayInstrumentDD : PLVPaymentInstrument

@property (strong) NSString* accountNumber;
@property (strong) NSString* routingNumber;
@end

/**
 *  PLVPayInstrumentSEPA    SEPA Account PaymentInstrument
 *
 *  @property iban          IBAN for this SEPA account
 *
 *  @property bic           BIC Number for this SEPA account
 *
 */

@interface PLVPayInstrumentSEPA : PLVPaymentInstrument

@property (strong) NSString* iban;
@property (strong) NSString* bic;

@end

/**
 *  PLVPayInstrumentPAYPAL  PayPal Account PaymentInstrument
 *
 *  @property authToken     authToken for this PayPal Account
 *
 */

@interface PLVPayInstrumentPAYPAL : PLVPaymentInstrument

@property (strong) NSString* authToken;

@end