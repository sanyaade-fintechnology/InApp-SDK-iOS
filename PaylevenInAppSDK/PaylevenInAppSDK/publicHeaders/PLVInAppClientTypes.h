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

/**
 *  createCreditCardPayInstrumentWithPan:expiryMonth:expiryYear:cvv:andCardHolder:
 *
 *  Creates a CreditCard payment Instrument
 *
 *  @param pan         the PAN for this creditcard
 *  @param expiryMonth the expiry month for this creditcard payment instrument
 *  @param expiryYear  the expiry year for this creditcard payment instrument
 *  @param cvv         the cvv for this creditcard payment instrument
 *  @param cardHolder  the name of the cardholder for this creditcard payment instrument as writen on the credit card
 *
 *  @return a PaymentInstrument of class PLVPayInstrumentCC presenting this creditcard
 */

+ (id)createCreditCardPayInstrumentWithPan:(NSString*)pan
                               expiryMonth:(NSInteger)expiryMonth
                                expiryYear:(NSInteger)expiryYear
                                       cvv:(NSString*)cvv
                             andCardHolder:(NSString*)cardHolder;



/**
 *  createDebitPayInstrumentWithAccountNo:andRoutingNo:
 *
 *  Creates a paymentinstrument presenting a debit account
 *
 *  @param accountNo The account number of this debit account
 *  @param routingNo The routing number of this debit account
 *
 *  @return  a PaymentInstrument of class PLVPayInstrumentDD presenting this debit account
 */
+ (id)createDebitPayInstrumentWithAccountNo:(NSString*)accountNo
                               andRoutingNo:(NSString*)routingNo;



/**
 *  createSEPAPayInstrumentWithIBAN:andBIC:
 *
 *  Creates a paymentinstrument presenting a SEPA account
 *
 *  @param iban       the iban for this SEPA account
 *  @param bic        the BIC for this SEPA account (optional)
 *
 *  @return  a PaymentInstrument of class PLVPayInstrumentSEPA presenting this SEPA account
 */

+ (id)createSEPAPayInstrumentWithIBAN:(NSString*)iban
                               andBIC:(NSString*)bic;



/**
 *  createPAYPALPayInstrumentWithToken:
 *
 *  Creates a paymentinstrument presenting a PayPal account
 *
 *  @param token       the token to get access to the paypal account
 *
 *  @return   a PaymentInstrument of class PLVPayInstrumentPAYPAL presenting this paypal account
 */

+ (id)createPAYPALPayInstrumentWithToken:(NSString*)token;



/**
 *  validatePayInstrumentReturningError:
 *
 *  @param outError error object
 *
 *  @return TRUE on passed validation and FALSE on missing validation
 */
- (BOOL) validatePaymentInstrumentWithError:(NSError **)outError;


@property (readonly,strong) NSString* type;
@property (readonly,strong) NSString* sortIndex;
@property (readonly,strong) NSString* identifier;

@end

/**
 *  PLVPayInstrumentCC      CrediCard PaymentInstrument
 *
 *  @property pan           pan of the Creditcard
 *
 *  @property cardBrand     the cardbrand of this card (will be present on polling payment instruments)
 *
 *  @property expiryMonth   the expiry month of this creditcard
 *
 *  @property expiryYear    the expiry year of this creditcard 4 digits (f.e. 2015 or 2018)
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

/**
 *  validatePan:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param pan   the pan value to validate
 *
 *  @param error resulting validation error, will not be set if string passed the validation
 *
 *  @return TRUE for a valid pan string ... otherwise FALSE
 */

+ (BOOL) validatePan:(NSString*)pan withError:(NSError **)error;

/**
 *  validateExpiryMonth:andYear:withError:
 *
 *  function to validates ExpiryMonth and ExpiryYear for matching certain criteria
 *
 *  @param month                the month value to validate
 *  @param year                 the year value to validate
 *
 *  @param error resulting validation error, will not be set if string passed the validation
 *
 *  @return TRUE for a valid month/year combination  ... otherwise FALSE
 */

+ (BOOL) validateExpiryMonth:(NSInteger)month andYear:(NSInteger)year withError:(NSError **)error;

/**
 *  validateCVV:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param cvv                  the cvv value to validate
 *
 *  @param error                resulting validation error, will not be set if string passed the validation
 *
 *  @return                     TRUE for a valid cvv string ... otherwise FALSE
 *
 *  attention: final cvv validation needs a attached pan ...
 *  so it can possible a value pass validation on this function and fail on validation on try to add a paymentinstrument
 *  refer to the resulting error
 */

+ (BOOL) validateCVV:(NSString*)cvv withError:(NSError **)error;

/**
 *  validateCardHolder:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param cardHolder           the cardHolder value to validate
 *  @param error resulting      validation error, will not be set if string passed the validation
 *
 *  @return                     TRUE for a valid cardHolder string ... otherwise FALSE
 */

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

/**
 *  validateAccountNo:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param accountNo            the accountNo value to validate
 *  @param error resulting      validation error, will not be set if string passed the validation
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
 *  @param error resulting      validation error, will not be set if string passed the validation
 *
 *  @return                     TRUE for a valid routingNumber string ... otherwise FALSE
 */

+ (BOOL) validateRoutingNo:(NSString*)routingNo withError:(NSError **)error;

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

/**
 *  validateIBAN:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param iban                 the IBAN value to validate
 *  @param error resulting      validation error, will not be set if string passed the validation
 *
 *  @return                     TRUE for a valid IBAN string ... otherwise FALSE
 */

+ (BOOL) validateIBAN:(NSString*)iban withError:(NSError **)error;

/**
 *  validateBIC:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param bic                  the bic value to validate
 *  @param error resulting      validation error, will not be set if string passed the validation
 *
 *  @return                     TRUE for a valid BIC string ... otherwise FALSE
 */

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

/**
 *  validateAuthToken:withError:
 *
 *  function to validate a string for matching certain criteria
 *
 *  @param authToken            the authToken value to validate
 *  @param error resulting      validation error, will not be set if string passed the validation
 *
 *  @return                     TRUE for a valid authToken string ... otherwise FALSE
 */

+ (BOOL) validateAuthToken:(NSString*)authToken withError:(NSError **)error;

@end