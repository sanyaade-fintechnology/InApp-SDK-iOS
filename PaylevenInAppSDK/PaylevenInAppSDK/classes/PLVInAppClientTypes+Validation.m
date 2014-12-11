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
#import "PLVInAppClientTypes+Validation.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "OrderedDictionary.h"
#import "PLVInAppClientTypPanValidator.h"

#define ccPANNumberMinLength 12
#define ccPANNumberMaxLength 21

#define ddaccountNoMinLength 8
#define ddaccountNoMaxLength 10

#define ddroutingNoMinLength 8
#define ddroutingNoMaxLength 9

#define sepaIBANNumberMinLength 10
#define sepaIBANNumberMaxLength 34

#define sepaBICNumberMinLength 8
#define sepaBICNumberMaxLength 11

#define paypalAuthTokenNumberMinLength 5
#define paypalAuthTokenNumberMaxLength 30



#define addError(validationErrors,errorCode,errorMessage) [validationErrors addObject:[NSError errorWithDomain:PLVAPIClientErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]]]

@implementation PLVPaymentInstrument (Validation)

- (NSError*)  validateOnCreation {
    
    return Nil;
}

- (NSArray*)validateOnUpdate {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (self.identifier == Nil || self.identifier.length == 0) {
        addError(validationErrors,ERROR_INVALID_PAYMENTINSTRUMENTS_CODE,ERROR_INVALID_PAYMENTINSTRUMENTS_MESSAGE);
    }
    
    if (self.sortIndex == Nil || self.sortIndex.length == 0) {
        addError(validationErrors,ERROR_INVALID_PAYMENTINSTRUMENTS_CODE,ERROR_INVALID_PAYMENTINSTRUMENTS_MESSAGE);
    }
    
    return validationErrors;
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

- (NSArray*) validExpiryDateForMonth:(NSString*)month andYear:(NSString*)year {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (![self containsOnlyDigits:month] || ![self containsOnlyDigits:year]) {
        addError(validationErrors,ERROR_DATE_INVALID_CHARS_CODE,ERROR_DATE_INVALID_CHARS_MESSAGE);
    }
    
    int yearInt = 2000 + [NSDecimalNumber decimalNumberWithString:year].intValue;
    int monthInt = [NSDecimalNumber decimalNumberWithString:month].intValue;
    
    if (monthInt > 12 || monthInt < 1) {
        addError(validationErrors,ERROR_DATE_MONTH_CODE,ERROR_DATE_MONTH_MESSAGE);
    }
    
    if (yearInt > 2050 || yearInt < 2010) {
        addError(validationErrors,ERROR_DATE_YEAR_CODE,ERROR_DATE_YEAR_MESSAGE);
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    
    if ((yearInt < components.year) || ((yearInt == components.year) && (monthInt < components.month))) {
        addError(validationErrors,ERROR_DATE_PASSED_CODE,ERROR_DATE_PASSES_MESSAGE);
    }
    
    return validationErrors;
}

@end


@implementation PLVPayInstrumentCC (Validation)

- (NSArray*) validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (self.pan == Nil || self.pan.length == 0) {
        addError(validationErrors,ERROR_CC_EMPTY_CODE,ERROR_CC_EMPTY_MESSAGE);
    }
        
    PLVInAppClientTypPanValidator* validator = [[PLVInAppClientTypPanValidator alloc] init];
    
    if (self.pan.length < [validator minLengthForPan:self.pan]) {
        addError(validationErrors,ERROR_CC_TOO_SHORT_CODE,ERROR_CC_TOO_SHORT_MESSAGE);
    }
    
    if (self.pan.length > [validator maxLengthForPan:self.pan]) {
        addError(validationErrors,ERROR_CC_TOO_LONG_CODE,ERROR_CC_TOO_LONG_MESSAGE);
    }
    
    if (self.pan.integerValue == 0) {
        addError(validationErrors,ERROR_CC_EMPTY_CODE,ERROR_CC_EMPTY_MESSAGE);
    }
    
    if ([validator doLuhnCheckForPan:self.pan]) {
        if (![self luhnCheck:self.pan]) {
            addError(validationErrors,ERROR_CC_LUM_FAILED_CODE,ERROR_CC_LUM_FAILED_MESSAGE);
        }
    }
    
    if (![self containsOnlyDigits:self.pan]) {
        addError(validationErrors,ERROR_CC_INVALID_CHARS_CODE,ERROR_CC_INVALID_CHARS_MESSAGE);
    }
    
    if (self.expiryMonth == Nil || self.expiryMonth.length == 0 || self.expiryYear == Nil || self.expiryYear.length == 0) {
        addError(validationErrors,ERROR_DATE_EMPTY_CODE,ERROR_DATE_EMPTY_MESSAGE);
    }
    
    [validationErrors addObjectsFromArray:[self validExpiryDateForMonth:self.expiryMonth andYear:self.expiryYear]];
    
    if (self.cvv == Nil || self.cvv.length == 0) {
        addError(validationErrors,ERROR_CVV_EMPTY_CODE,ERROR_CVV_EMPTY_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.cvv]) {
        addError(validationErrors,ERROR_CVV_INVALID_CHARS_CODE,ERROR_CVV_INVALID_CHARS_MESSAGE);
    }
    
    if (self.cvv.length != [validator cvvlengthForPan:self.pan]) {
        addError(validationErrors,ERROR_CVV_INVALID_LENGTH_CODE,ERROR_CVV_INVALID_LENGTH_MESSAGE);
    }

    return validationErrors;
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

- (NSArray*)   validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (self.accountNo == Nil || self.accountNo.length == 0) {
        addError(validationErrors,ERROR_DD_ACCOUNT_MISSING_CODE,ERROR_DD_ACCOUNT_MISSING_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.accountNo]) {
        addError(validationErrors,ERROR_DD_ACCOUNT_INVALID_CHARS_CODE,ERROR_DD_ACCOUNT_INVALID_CHARS_MESSAGE);
    }
    
    if (self.accountNo.length < ddaccountNoMinLength) {
        addError(validationErrors,ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE,ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE);
    }
    
    if (self.accountNo.length > ddaccountNoMaxLength) {
        addError(validationErrors,ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE,ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE);
    }
    
    if (self.accountNo.integerValue == 0) {
        addError(validationErrors,ERROR_DD_ACCOUNT_MISSING_CODE,ERROR_DD_ACCOUNT_MISSING_MESSAGE);
    }
    
    
    if (self.routingNo == Nil || self.routingNo.length == 0) {
        addError(validationErrors,ERROR_DD_ROUTING_MISSING_CODE,ERROR_DD_ROUTING_MISSING_MESSAGE);
    }

    
    if (self.routingNo.integerValue == 0) {
        addError(validationErrors,ERROR_DD_ROUTING_MISSING_CODE,ERROR_DD_ROUTING_MISSING_MESSAGE);
    }
    
    if (![self containsOnlyDigits:self.routingNo]) {
        addError(validationErrors,ERROR_DD_ROUTING_INVALID_CHARS_CODE,ERROR_DD_ROUTING_INVALID_CHARS_MESSAGE);
    }
    
    if (self.routingNo.length < ddroutingNoMinLength) {
        addError(validationErrors,ERROR_DD_ROUTING_INVALID_LENGTH_CODE,ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE);
    }
    
    if (self.routingNo.length > ddroutingNoMaxLength) {
        addError(validationErrors,ERROR_DD_ROUTING_INVALID_LENGTH_CODE,ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE);
    }
    
    return validationErrors;
}

@end


@implementation PLVPayInstrumentSEPA (Validation)


- (NSError*)   validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (self.iban == Nil || self.iban.length == 0) {
        addError(validationErrors,ERROR_SEPA_IBAN_EMPTY_CODE,ERROR_SEPA_IBAN_EMPTY_MESSAGE);
    }
    
    if (self.iban.length < sepaIBANNumberMinLength || self.iban.length > sepaIBANNumberMaxLength) {
        addError(validationErrors,ERROR_SEPA_IBAN_INVALID_LENGTH_CODE,ERROR_SEPA_IBAN_INVALID_LENGTH_MESSAGE);
    }
    
    if ([self.iban substringFromIndex:2].integerValue == 0) {
        addError(validationErrors,ERROR_SEPA_IBAN_EMPTY_CODE,ERROR_SEPA_IBAN_EMPTY_MESSAGE);
    }
    
    if (![self containsDigits:[self.iban substringToIndex:2]]) {
        addError(validationErrors,ERROR_SEPA_IBAN_INVALID_CHARS_CODE,ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE);
    }
    
    if (![self containsOnlyDigits:[self.iban substringWithRange:NSMakeRange(2, 2)]]) {
        addError(validationErrors,ERROR_SEPA_IBAN_INVALID_CHARS_CODE,ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE);
    }
    
    if (![self checkIBAN:self.iban]) {
        addError(validationErrors,ERROR_SEPA_IBAN_INVALID_CODE,ERROR_SEPA_IBAN_INVALID_MESSAGE);
    }
    
    if (self.bic == Nil || self.bic.length == 0) {
        
        ;  // optinal
        
        return Nil;
    }
    
    if (self.bic.integerValue == 0) {
        addError(validationErrors,ERROR_SEPA_BIC_EMPTY_CODE ,ERROR_SEPA_BIC_EMPTY_MESSAGE);
    }
    
    if (self.bic.length < sepaBICNumberMinLength || self.bic.length > sepaBICNumberMaxLength) {
        addError(validationErrors,ERROR_SEPA_BIC_INVALID_LENGTH_CODE,ERROR_SEPA_BIC_INVALID_LENGTH_MESSAGE);
    }
    
    return Nil;
}


- (BOOL) checkIBAN:(NSString*)ibanInput {
    
    NSMutableString* iban = [NSMutableString stringWithString:[ibanInput substringFromIndex:4]];
    
    //Move the four initial characters to the end of the string
    NSString* countryPrefix = [[ibanInput substringToIndex:2] lowercaseString];
    
    //Replace the letters in the string with digits, expanding the string as necessary,
    // such that A or a = 10, B or b = 11, and Z or z = 35.
    // Each alphabetic character is therefore replaced by 2 digits
    
    const char* countryCode = [countryPrefix cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned short digitValue = 0;
    
    for (int index = 0; index < 2; index++) {
        
        digitValue = (unsigned short) countryCode[index];
        
        digitValue = digitValue - 87;
        
        if (digitValue < 10 || digitValue > 35) {
            // invalid digits
            return FALSE;
        }
        
        [iban appendString:[[NSNumber numberWithShort:digitValue] stringValue]];
    }
    
    [iban appendString:[ibanInput substringWithRange:NSMakeRange(2, 2)]];
    
    // check for containing non digit letters
    
    NSRange currentRange;
    
    for (int ibanStringPostion = (int)iban.length - 1; ibanStringPostion >= 0; ibanStringPostion --) {
        
        currentRange = NSMakeRange(ibanStringPostion, 1);
        
        if (![self containsOnlyDigits:[iban substringWithRange:currentRange]]) {
            
            NSString* specific = [[iban substringWithRange:currentRange] lowercaseString];
            
            const char* specificCode = [specific cStringUsingEncoding:NSASCIIStringEncoding];
            
            unsigned short digitValue = 0;
            
            digitValue = (unsigned short) specificCode[0];
            
            if (digitValue > 96 && digitValue < 123) {
                // letter
                
                digitValue = digitValue - 87;
                
                [iban replaceCharactersInRange:currentRange withString:[[NSNumber numberWithShort:digitValue] stringValue]];
            }
            
            }
        }
    
    if (iban.length < 39) {
        
        NSDecimalNumber* ibanDecimalNumber = [NSDecimalNumber decimalNumberWithString:iban];
        
        NSDecimalNumber* mod = [ibanDecimalNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"97"] withBehavior:(id <NSDecimalNumberBehaviors>)self];
        
        NSDecimalNumber* reminder = [ibanDecimalNumber decimalNumberBySubtracting:[[NSDecimalNumber decimalNumberWithString:@"97"] decimalNumberByMultiplyingBy:mod]];
        
        return 1 == reminder.intValue;
        
    } else {
        
        NSString* firstPart = [iban substringToIndex:38];
        
        NSDecimalNumber* ibanDecimalNumber = [NSDecimalNumber decimalNumberWithString:firstPart];
        
        NSDecimalNumber* mod = [ibanDecimalNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"97"] withBehavior:(id <NSDecimalNumberBehaviors>)self];
        
        NSDecimalNumber* reminder = [ibanDecimalNumber decimalNumberBySubtracting:[[NSDecimalNumber decimalNumberWithString:@"97"] decimalNumberByMultiplyingBy:mod]];
        
        
        NSString* secondPart = [NSString stringWithFormat:@"%@%@",[reminder stringValue],[iban substringFromIndex:38]];
        
        ibanDecimalNumber = [NSDecimalNumber decimalNumberWithString:secondPart];
        
        mod = [ibanDecimalNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"97"] withBehavior:(id <NSDecimalNumberBehaviors>)self];
        
        reminder = [ibanDecimalNumber decimalNumberBySubtracting:[[NSDecimalNumber decimalNumberWithString:@"97"] decimalNumberByMultiplyingBy:mod]];
        
        return 1 == reminder.intValue;
    }
}

- (NSRoundingMode)roundingMode {
    
    return NSRoundDown;
}

- (short)scale {
    
    return 0;
}
// The scale could return NO_SCALE for no defined scale.

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)operation error:(NSCalculationError)error leftOperand:(NSDecimalNumber *)leftOperand rightOperand:(NSDecimalNumber *)rightOperand {
    
    return [NSDecimalNumber decimalNumberWithString:@"0"];
}


@end

@implementation PLVPayInstrumentPAYPAL (Validation)

- (NSArray*)   validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (self.authToken == Nil || self.authToken.length == 0) {
        addError(validationErrors,ERROR_PAYPAL_TOKEN_EMPTY_CODE,ERROR_PAYPAL_TOKEN_EMPTY_MESSAGE);
    }
    
    if (self.authToken.length < paypalAuthTokenNumberMinLength || self.authToken.length > paypalAuthTokenNumberMaxLength) {
        addError(validationErrors,ERROR_PAYPAL_TOKEN_INVALID_CODE,ERROR_PAYPAL_TOKEN_INVALID_MESSAGE);
    }
    
    return validationErrors;
}

@end




