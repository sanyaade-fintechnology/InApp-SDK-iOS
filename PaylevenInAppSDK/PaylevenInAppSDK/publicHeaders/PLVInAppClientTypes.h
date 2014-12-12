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
          expiryMonth:(NSString*)expiryMonth
           expiryYear:(NSString*)expiryYear
                  cvv:(NSString*)cvv
        andCardHolder:(NSString*)cardHolder;


+ (id)createDDWithAccountNo:(NSString*)accountNo
               andRoutingNo:(NSString*)routingNo;


+ (id)createSEPAWithIBAN:(NSString*)iban
                  andBIC:(NSString*)bic;

+ (id)createPAYPALWithToken:(NSString*)token;



/**
 *  validate The PaymentInstrument
 *
 *  @return returns array containing a NSError objects for every single validation error
 */
- (NSArray*) validate;

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
@property (readonly,strong) NSString* expiryMonth;
@property (readonly,strong) NSString* expiryYear;
@property (readonly,strong) NSString* cvv;
@property (readonly,strong) NSString* cardHolder;

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

@end

/**
 *  PLVPayInstrumentPAYPAL  PayPal Account PaymentInstrument
 *
 *  @property authToken     authToken for this PayPal Account
 *
 */

@interface PLVPayInstrumentPAYPAL : PLVPaymentInstrument

@property (readonly,strong) NSString* authToken;

@end