//
//  PLVInAppClientErrors.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 18.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;


@interface PLVInAppClientErrors : NSObject

extern NSInteger const ERROR_INVALID_BACKEND_RESPONSE_CODE;

extern NSString * const ERROR_INVALID_BACKEND_RESPONSE_MESSAGE;

extern NSInteger const ERROR_MISSING_API_KEY_CODE;
extern NSString * const ERROR_MISSING_API_KEY_MESSAGE;

extern NSInteger  const ERROR_MISSING_CALLBACK_CODE;
extern NSString * const ERROR_MISSING_CALLBACK_MESSAGE;

extern NSInteger const ERROR_MISSING_EMAILADDRESS_CODE;
extern NSString * const ERROR_MISSING_EMAILADDRESS_MESSAGE;

extern NSInteger const ERROR_INVALID_EMAILADDRESS_CODE;
extern NSString * const ERROR_INVALID_EMAILADDRESS_MESSAGE;

extern NSInteger const ERROR_MISSING_USERTOKEN_CODE;
extern NSString * const ERROR_MISSING_USERTOKEN_MESSAGE;

extern NSInteger const ERROR_MISSING_PAYMENTINSTRUMENTS_CODE;
extern NSString * const ERROR_MISSING_PAYMENTINSTRUMENTS_MESSAGE;


extern NSInteger const ERROR_CC_EMPTY_CODE;
extern NSString * const ERROR_CC_EMPTY_MESSAGE;

extern NSInteger const ERROR_CC_INVALID_CODE;
extern NSString * const ERROR_CC_INVALID_MESSAGE;

extern NSInteger const ERROR_CC_INVALID_CHARS_CODE;
extern NSString * const ERROR_CC_INVALID_CHARS_MESSAGE;

extern NSInteger const ERROR_CC_TOO_SHORT_CODE;
extern NSString * const ERROR_CC_TOO_SHORT_MESSAGE;

extern NSInteger const ERROR_CC_TOO_LONG_CODE;
extern NSString * const ERROR_CC_TOO_LONG_MESSAGE;

extern NSInteger const ERROR_CC_LUM_FAILED_CODE;
extern NSString * const ERROR_CC_LUM_FAILED_MESSAGE;



extern NSInteger const ERROR_SEPA_IBAN_EMPTY_CODE;
extern NSString * const ERROR_SEPA_IBAN_EMPTY_MESSAGE;

extern NSInteger const ERROR_SEPA_IBAN_INVALID_LENGTH_CODE;
extern NSString * const ERROR_SEPA_IBAN_INVALID_LENGTH_MESSAGE;

extern NSInteger const ERROR_SEPA_IBAN_INVALID_CHARS_CODE;
extern NSString * const ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE;

extern NSInteger const ERROR_SEPA_IBAN_INVALID_CODE;
extern NSString * const ERROR_SEPA_IBAN_INVALID_MESSAGE;





extern NSInteger const ERROR_DD_ACCOUNT_MISSING_CODE;
extern NSString * const ERROR_DD_ACCOUNT_MISSING_MESSAGE;

extern NSInteger const ERROR_DD_ACCOUNT_INVALID_CHARS_CODE;
extern NSString * const ERROR_DD_ACCOUNT_INVALID_CHARS_MESSAGE;

extern NSInteger const ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE;
extern NSString * const ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE;



extern NSInteger const ERROR_DD_ROUTING_MISSING_CODE;
extern NSString * const ERROR_DD_ROUTING_MISSING_MESSAGE;

extern NSInteger const ERROR_DD_ROUTING_INVALID_CHARS_CODE;
extern NSString * const ERROR_DD_ROUTING_INVALID_CHARS_MESSAGE;

extern NSInteger const ERROR_DD_ROUTING_INVALID_LENGTH_CODE;
extern NSString * const ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE;




extern NSInteger const ERROR_PAYPAL_TOKEN_EMPTY_CODE;
extern NSString * const ERROR_PAYPAL_TOKEN_EMPTY_MESSAGE;

extern NSInteger const ERROR_PAYPAL_TOKEN_INVALID_CODE;
extern NSString * const ERROR_PAYPAL_TOKEN_INVALID_MESSAGE;




extern NSInteger const ERROR_DATE_EMPTY_CODE;
extern NSString * const ERROR_DATE_EMPTY_MESSAGE;

extern NSInteger const ERROR_DATE_INVALID_CHARS_CODE;
extern NSString * const ERROR_DATE_INVALID_CHARS_MESSAGE;

extern NSInteger const ERROR_DATE_MONTH_CODE;
extern NSString * const ERROR_DATE_MONTH_MESSAGE;

extern NSInteger const ERROR_DATE_YEAR_CODE;
extern NSString * const ERROR_DATE_YEAR_MESSAGE;

extern NSInteger const ERROR_DATE_PASSED_CODE;
extern NSString * const ERROR_DATE_PASSES_MESSAGE;



extern NSInteger const ERROR_CVV_EMPTY_CODE;
extern NSString * const ERROR_CVV_EMPTY_MESSAGE;

extern NSInteger const ERROR_CVV_INVALID_CHARS_CODE;
extern NSString * const ERROR_CVV_INVALID_CHARS_MESSAGE;

extern NSInteger const ERROR_CVV_INVALID_LENGTH_CODE;
extern NSString * const ERROR_CVV_INVALID_LENGTH_MESSAGE;

@end

