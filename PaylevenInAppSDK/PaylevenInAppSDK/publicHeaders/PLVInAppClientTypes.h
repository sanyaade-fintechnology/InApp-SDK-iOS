//
//  PLVInAppClientTypes.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

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

+ (id)createCCWithPan:(NSString*)pan
          expiryMonth:(NSInteger)expiryMonth
           expiryYear:(NSInteger)expiryYear
                  cvv:(NSString*)cvv
        andCardHolder:(NSString*)cardHolder;


+ (id)createDDWithAccountNo:(NSString*)accountNo
               andRoutingNo:(NSString*)routingNo;


+ (id)createSEPAWithIBAN:(NSString*)iban
                  andBIC:(NSString*)bic;

+ (id)createPAYPALWithToken:(NSString*)token;


/**
 *  validatePayInstrumentReturningError
 *
 *  @param outError error object
 *
 *  @return TRUE on passed validation and FALSE on missing validation
 */
- (BOOL) validatePayInstrumentReturningError:(NSError **)outError;


@property (readonly,strong) NSString* type;
@property (readonly,strong) NSString* sortIndex;
@property (readonly,strong) NSString* identifier;

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

@property (readonly,strong) NSString* pan;
@property (readonly,strong) NSString* cardBrand;
@property (readonly,nonatomic) NSInteger expiryMonth;
@property (readonly,nonatomic) NSInteger expiryYear;
@property (readonly,strong) NSString* cvv;
@property (readonly,strong) NSString* cardHolder;

+ (BOOL) validatePan:(NSString*)pan withError:(NSError **)error;
+ (BOOL) validateExpiryMonth:(NSInteger)month andYear:(NSInteger)year withError:(NSError **)error;
+ (BOOL) validateCVV:(NSString*)cvv withError:(NSError **)error;
+ (BOOL) validateCardHolder:(NSString*)cardHolder withError:(NSError **)error;

@end




/**
 *  PLVPayInstrumentDD      Debit PaymentInstrument
 *
 *  @property accountNo accountNumber for this debit account
 *
 *  @property routingNo routingNumber for this debit account
 *
 */

@interface PLVPayInstrumentDD : PLVPaymentInstrument

@property (readonly,strong) NSString* accountNo;
@property (readonly,strong) NSString* routingNo;

+ (BOOL) validateAccountNo:(NSString*)accountNo withError:(NSError **)error;
+ (BOOL) validateRoutingNo:(NSString*)routningNo withError:(NSError **)error;

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

@property (readonly,strong) NSString* iban;
@property (readonly,strong) NSString* bic;

+ (BOOL) validateIBAN:(NSString*)iban withError:(NSError **)error;
+ (BOOL) validateBIC:(NSString*)bic withError:(NSError **)error;

@end

/**
 *  PLVPayInstrumentPAYPAL  PayPal Account PaymentInstrument
 *
 *  @property authToken     authToken for this PayPal Account
 *
 */

@interface PLVPayInstrumentPAYPAL : PLVPaymentInstrument

@property (readonly,strong) NSString* authToken;

+ (BOOL) validateAuthToken:(NSString*)authToken withError:(NSError **)error;

@end