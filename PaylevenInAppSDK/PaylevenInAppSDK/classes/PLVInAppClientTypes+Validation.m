//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

#import "PLVInAppSDKConstants.h"
#import "PLVInAppErrors.h"
#import "PLVInAppClientTypes.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "OrderedDictionary.h"

#define ccPANNumberMinLength 9
#define ccPANNumberMaxLength 21


#define ddAccountNumberMinLength 5
#define ddAccountNumberMaxLength 30


#define ddRoutingNumberMinLength 5
#define ddRoutingNumberMaxLength 30

#define sepaIBANNumberMinLength 5
#define sepaIBANNumberMaxLength 30


#define sepaBICNumberMinLength 5
#define sepaBICNumberMaxLength 30


#define paypalAuthTokenNumberMinLength 5
#define paypalAuthTokenNumberMaxLength 30



#define CreateError(errorCode,errorMessage) [NSError errorWithDomain:PLVAPIClientErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]]

@implementation PLVPaymentInstrument (Validation)

- (NSError*)  validateOnCreation {
    
    return Nil;
}

- (NSError*)validateOnUpdate {
    
    if (self.identifier == Nil || self.identifier.length == 0) {
        return CreateError(ERROR_DATE_MONTH_CODE,ERROR_DATE_MONTH_MESSAGE);
    }
    
    if (self.sortIndex == Nil || self.sortIndex.length == 0) {
        return CreateError(ERROR_DATE_YEAR_CODE,ERROR_DATE_YEAR_MESSAGE);
    }
    
    return Nil;
}

- (BOOL) containsOnlyDigits:(NSString*)valueToCheck {

    NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if ([valueToCheck rangeOfCharacterFromSet:nonDigits].location != NSNotFound)
    {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL) containsDigits:(NSString*)valueToCheck {
    
    NSCharacterSet* digits = [NSCharacterSet decimalDigitCharacterSet];
    
    if ([valueToCheck rangeOfCharacterFromSet:digits].location != NSNotFound)
    {
        return TRUE;
    }
    
    return TRUE;
}

- (NSError*) validExpiryDateForMonth:(NSString*)month andYear:(NSString*)year {
    
    if (![self containsOnlyDigits:month] || ![self containsOnlyDigits:year]) {
        return CreateError(ERROR_DATE_INVALID_CHARS_CODE,ERROR_DATE_INVALID_CHARS_MESSAGE);
    }
    
    int yearInt = 2000 + [NSDecimalNumber decimalNumberWithString:year].intValue;
    int monthInt = [NSDecimalNumber decimalNumberWithString:month].intValue;
    
    if (monthInt > 12 || monthInt < 1) {
        return CreateError(ERROR_DATE_MONTH_CODE,ERROR_DATE_MONTH_MESSAGE);
    }
    
    if (yearInt > 2050 || yearInt < 2010) {
        return CreateError(ERROR_DATE_YEAR_CODE,ERROR_DATE_YEAR_MESSAGE);
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    
    if ((yearInt < components.year) || ((yearInt == components.year) && (monthInt < components.month))) {
        return CreateError(ERROR_DATE_PASSED_CODE,ERROR_DATE_PASSES_MESSAGE);
    }
    
    return Nil;
}

@end


@implementation PLVPayInstrumentCC (Validation)

- (NSError*)   validateOnCreation {
    
    if (self.pan == Nil || self.pan.length == 0) {
        return CreateError(ERROR_CC_EMPTY_CODE,ERROR_CC_EMPTY_MESSAGE);
    }
    
    if (self.pan.length < ccPANNumberMinLength) {
        return CreateError(ERROR_CC_TOO_SHORT_CODE,ERROR_CC_TOO_SHORT_MESSAGE);
    }
    
    if (self.pan.length > ccPANNumberMaxLength) {
        return CreateError(ERROR_CC_TOO_LONG_CODE,ERROR_CC_TOO_LONG_MESSAGE);
    }
    
    if (![self luhnCheck:self.pan]) {
        //return CreateError(ERROR_CC_LUM_FAILED_CODE,ERROR_CC_LUM_FAILED_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.pan]) {
        return CreateError(ERROR_CC_INVALID_CHARS_CODE,ERROR_CC_INVALID_CHARS_MESSAGE);
    }
    
    if (self.expiryMonth == Nil || self.expiryMonth.length == 0 || self.expiryYear == Nil || self.expiryYear.length == 0) {
        return CreateError(ERROR_DATE_EMPTY_CODE,ERROR_DATE_EMPTY_MESSAGE);
    }
    
    NSError* expiryDateError = [self validExpiryDateForMonth:self.expiryMonth andYear:self.expiryYear];
    
    if (expiryDateError != Nil) {
        return expiryDateError;
    }
    
    if (self.cvv == Nil || self.cvv.length == 0) {
        return CreateError(ERROR_CVV_EMPTY_CODE,ERROR_CVV_EMPTY_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.cvv]) {
        return CreateError(ERROR_CVV_INVALID_CHARS_CODE,ERROR_CVV_INVALID_CHARS_MESSAGE);
    }
    
    int ccvLength = 3;
    
    if ([self.pan hasPrefix:@"37"] || [self.pan hasPrefix:@"34"]) {
        // should be a AMEX card, so we aspect 4 digit for the cvv
        ccvLength = 4;
    }
    
    if (self.cvv.length != ccvLength) {
        return CreateError(ERROR_CVV_INVALID_LENGTH_CODE,ERROR_CVV_INVALID_LENGTH_MESSAGE);
    }

    return Nil;
}

- (BOOL) luhnCheck:(NSString *)stringToTest
{
    NSMutableArray *stringAsChars = [self toCharArray:stringToTest];
    
    BOOL isOdd = YES;
    int oddSum = 0;
    int evenSum = 0;
    
    for (NSInteger i = [stringToTest length] - 1; i >= 0; i--) {
        
        int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
        
        if (isOdd)
            oddSum += digit;
        else
            evenSum += digit/5 + (2*digit) % 10;
        
        isOdd = !isOdd;
    }
    
    return ((oddSum + evenSum) % 10 == 0);
}

- (NSMutableArray *) toCharArray:(NSString*)chars
{
    NSMutableArray *charsToCheck = [[NSMutableArray alloc] initWithCapacity:[chars length]];
    for (int i=0; i < [chars length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [chars characterAtIndex:i]];
        [charsToCheck addObject:ichar];
    }
    
    return charsToCheck;
}

@end


@implementation PLVPayInstrumentDD (Validation)

- (NSError*)   validateOnCreation {
    
    
    if (self.accountNumber == Nil || self.accountNumber.length == 0) {
        return CreateError(ERROR_DD_ACCOUNT_MISSING_CODE,ERROR_DD_ACCOUNT_MISSING_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.accountNumber]) {
        return CreateError(ERROR_DD_ACCOUNT_INVALID_CHARS_CODE,ERROR_DD_ACCOUNT_INVALID_CHARS_MESSAGE);
    }
    
    if (self.accountNumber.length < ddAccountNumberMinLength) {
        return CreateError(ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE,ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE);
    }
    
    if (self.accountNumber.length > ddAccountNumberMaxLength) {
        return CreateError(ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE,ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE);
    }
    
    
    
    
    if (self.routingNumber == Nil || self.routingNumber.length == 0) {
        return CreateError(ERROR_DD_ROUTING_MISSING_CODE,ERROR_DD_ROUTING_MISSING_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.routingNumber]) {
        return CreateError(ERROR_DD_ROUTING_INVALID_CHARS_CODE,ERROR_DD_ROUTING_INVALID_CHARS_MESSAGE);
    }
    
    if (self.routingNumber.length < ddRoutingNumberMinLength) {
        return CreateError(ERROR_DD_ROUTING_INVALID_LENGTH_CODE,ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE);
    }
    
    if (self.routingNumber.length > ddRoutingNumberMaxLength) {
        return CreateError(ERROR_DD_ROUTING_INVALID_LENGTH_CODE,ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE);
    }
    
    return Nil;
}

@end


@implementation PLVPayInstrumentSEPA (Validation)


- (NSError*)   validateOnCreation {
    
    if (self.iban == Nil || self.iban.length == 0) {
        return CreateError(ERROR_SEPA_IBAN_EMPTY_CODE,ERROR_SEPA_IBAN_EMPTY_MESSAGE);
    }
    
    if (self.iban.length < sepaIBANNumberMinLength || self.iban.length > sepaIBANNumberMaxLength) {
        return CreateError(ERROR_SEPA_IBAN_INVALID_LENGTH_CODE,ERROR_SEPA_IBAN_INVALID_LENGTH_MESSAGE);
    }
    
    if (![self containsDigits:[self.iban substringToIndex:2]]) {
        return CreateError(ERROR_SEPA_IBAN_INVALID_CHARS_CODE,ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE);
    }
    
    if (![self containsOnlyDigits:[self.iban substringFromIndex:2]]) {
        return CreateError(ERROR_SEPA_IBAN_INVALID_CHARS_CODE,ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE);
    }

    return Nil;
}


@end

@implementation PLVPayInstrumentPAYPAL (Validation)

- (NSError*)   validateOnCreation {
    
    if (self.authToken == Nil || self.authToken.length == 0) {
        return CreateError(ERROR_PAYPAL_TOKEN_EMPTY_CODE,ERROR_PAYPAL_TOKEN_EMPTY_MESSAGE);
    }
    
    if (self.authToken.length < paypalAuthTokenNumberMinLength || self.authToken.length > paypalAuthTokenNumberMaxLength) {
        return CreateError(ERROR_PAYPAL_TOKEN_INVALID_CODE,ERROR_PAYPAL_TOKEN_INVALID_MESSAGE);
    }
    
    return Nil;
}

@end




