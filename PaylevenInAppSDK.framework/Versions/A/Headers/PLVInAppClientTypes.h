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
 *  Base class of PaymentInstruments
 *
 */

@interface PLVPaymentInstrument : NSObject

/**
 *  createCreditCardPaymentInstrumentWithPan:expiryMonth:expiryYear:cvv:andCardHolder:
 *
 *  Creates a PaymentInstrument representing a Credit Card
 *
 *  @param pan         PAN of this credit card
 *  @param expiryMonth expiry month for this creditcard payment instrument
 *  @param expiryYear  expiry year for this creditcard payment instrument
 *  @param cvv         CVV for this creditcard payment instrument
 *  @param cardHolder  Name of the card holder of this credit card payment instrument as visible on the card
 *
 *  @return a PaymentInstrument of class PLVPayInstrumentCC representing this Credit card
 */

+ (id)createCreditCardPaymentInstrumentWithPan:(NSString*)pan
                                   expiryMonth:(NSInteger)expiryMonth
                                    expiryYear:(NSInteger)expiryYear
                                           cvv:(NSString*)cvv
                                 andCardHolder:(NSString*)cardHolder;



/**
 *  createDebitCardPaymentInstrumentWithAccountNo:andRoutingNo:
 *
 *  Creates a PaymentInstrument representing a Debit account
 *
 *  @param accountNo Account number of this debit account
 *  @param routingNo Routing number of this debit account
 *
 *  @return  a PaymentInstrument of class PLVPayInstrumentDD presenting this Debit account
 */
+ (id)createDebitCardPaymentInstrumentWithAccountNo:(NSString*)accountNo
                                       andRoutingNo:(NSString*)routingNo;



/**
 *  createSEPAPaymentInstrumentWithIBAN:andBIC:
 *
 *  Creates a PaymentInstrument representing a SEPA account
 *
 *  @param iban       IBAN of this SEPA account
 *  @param bic        BIC of this SEPA account (optional)
 *
 *  @return  a PaymentInstrument of class PLVPayInstrumentSEPA representing this SEPA account
 */

+ (id)createSEPAPaymentInstrumentWithIBAN:(NSString*)iban
                                   andBIC:(NSString*)bic;



/**
 *  createPAYPALPaymentInstrumentWithToken:
 *
 *  Creates a PaymentInstrument representing a PayPal account
 *
 *  @param token       Token to get access to the PayPal account
 *
 *  @return   a PaymentInstrument of class PLVPayInstrumentPAYPAL representing this PayPal account
 */

+ (id)createPAYPALPaymentInstrumentWithToken:(NSString*)token;



/**
 *  validatePayInstrumentReturningError:
 *
 *  @param outError error object
 *
 *  @return TRUE on passed validation and FALSE on unsuccessful validation
 */
- (BOOL) validatePaymentInstrumentWithError:(NSError **)outError;

/**
 *  Base class of PaymentInstruments
 *
 *
 */

@property (readonly,strong) NSString* type;
/** Identifier of PaymentInstrument (readonly) */
@property (readonly,strong) NSString* identifier;

@end

/**
 *  Credit Card PaymentInstrument
 *
 *
 */
@interface PLVCreditCardPaymentInstrument : PLVPaymentInstrument

/** PAN of Credit card */
@property (readonly,strong) NSString* pan;
/** Card Brand of Credit card */
@property (readonly,strong) NSString* cardBrand;
/** Expiry month of Credit card, Format MM (valid Range from 01 ... 12) */
@property (readonly,nonatomic) NSInteger expiryMonth;
/** Expiry year of Credit card, Format YYYY (valid Range from 2010 ... 2050) */
@property (readonly,nonatomic) NSInteger expiryYear;
/** Card Verification Value of Credit card */
@property (readonly,strong) NSString* cvv;
/** Card holder name of Credit card as visible on card*/
@property (readonly,strong) NSString* cardHolder;

/**
 *  validatePan:withError:
 *
 *  function to validate PAN
 *
 *  @param pan   PAN value to validate
 *
 *  @param error            resulting validation error, will be nil if PAN passes the validation
 *
 *  @return TRUE for a valid PAN string ... otherwise FALSE
 */

+ (BOOL) validatePan:(NSString*)pan withError:(NSError **)error;

/**
 *  validateExpiryMonth:andYear:withError:
 *
 *  function to validate ExpiryMonth and ExpiryYear
 *
 *  @param month                Month value to validate
 *  @param year                 Year value to validate
 *
 *  @param error                resulting validation error, will be nil if values pass the validation
 *
 *  @return TRUE for a valid Month/Year combination  ... otherwise FALSE
 */

+ (BOOL) validateExpiryMonth:(NSInteger)month andYear:(NSInteger)year withError:(NSError **)error;

/**
 *  validateCVV:withError:
 *
 *  function to validate CVV
 *
 *  @param cvv                  CVV value to validate
 *
 *  @param error                resulting validation error, will be nil if CVV passes the validation
 *
 *  @return                     TRUE for a valid CVV string ... otherwise FALSE
 *
 *  Attention: Final CVV validation will also take PAN into consideration. Even though validation returns TRUE here it might get rejected later on in addPaymentInstrument Method, please refer to the method's Error in this case.
 */

+ (BOOL) validateCVV:(NSString*)cvv withError:(NSError **)error;

/**
 *  validateCardHolder:withError:
 *
 *  function to validate Card holder
 *
 *  @param cardHolder           cardHolder value to validate
 *  @param error                resulting validation error, will be nil if Card holder passes the validation
 *
 *  @return                     TRUE for a valid cardHolder string ... otherwise FALSE
 */

+ (BOOL) validateCardHolder:(NSString*)cardHolder withError:(NSError **)error;

@end




/**
 *  Debit Card PaymentInstrument
 *
 *
 */

@interface PLVDebitCardPaymentInstrument : PLVPaymentInstrument
/** Account number for this debit account */
@property (readonly,strong) NSString* accountNo;
/** Routing number for this debit account */
@property (readonly,strong) NSString* routingNo;

/**
 *  validateAccountNo:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param accountNo            the accountNo value to validate
 *  @param error                resulting validation error, will be nil if Account number passes the validation
 *
 *  @return                     TRUE for a valid accountNumber string ... otherwise FALSE
 */

+ (BOOL) validateAccountNo:(NSString*)accountNo withError:(NSError **)error;

/**
 *  validateRoutingNo:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param routingNo            the routingNo value to validate
 *  @param error                resulting validation error, will be nil if Routing number passes the validation
 *
 *  @return                     TRUE for a valid routingNumber string ... otherwise FALSE
 */

+ (BOOL) validateRoutingNo:(NSString*)routingNo withError:(NSError **)error;

@end

/**
 *  SEPA Account PaymentInstrument
 *
 *
 */

@interface PLVSEPAPaymentInstrument : PLVPaymentInstrument

/** IBAN for this SEPA account */
@property (readonly,strong) NSString* iban;
/** BIC for this SEPA account */
@property (readonly,strong) NSString* bic;

/**
 *  validateIBAN:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param iban                 IBAN value to validate
 *  @param error                resulting validation error, will be nil if IBAN passes the validation
 *
 *  @return                     TRUE for a valid IBAN string ... otherwise FALSE
 */

+ (BOOL) validateIBAN:(NSString*)iban withError:(NSError **)error;

/**
 *  validateBIC:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param bic                  BIC value to validate
 *  @param error                resulting validation error, will be nil if BIC passes the validation
 *
 *  @return                     TRUE for a valid BIC string ... otherwise FALSE
 */

+ (BOOL) validateBIC:(NSString*)bic withError:(NSError **)error;

@end

/**
 *  PayPal Account PaymentInstrument
 *
 *
 */

@interface PLVPAYPALPaymentInstrument : PLVPaymentInstrument

/** Authentication Token for this PayPal Account */
@property (readonly,strong) NSString* authToken;

/**
 *  validateAuthToken:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param authToken            authToken value to validate
 *  @param error                resulting validation error, will be nil if Auth Token passes the validation
 *
 *  @return                     TRUE for a valid authToken string ... otherwise FALSE
 */

+ (BOOL) validateAuthToken:(NSString*)authToken withError:(NSError **)error;

@end