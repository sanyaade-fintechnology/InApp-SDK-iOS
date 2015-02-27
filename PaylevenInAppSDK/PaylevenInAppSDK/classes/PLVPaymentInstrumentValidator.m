//
//  PLVPaymentInstrumentValidator.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

#import "PLVInAppSDKConstants.h"
#import "PLVInAppErrors.h"
#import "PLVPaymentInstrumentValidator.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "OrderedDictionary.h"
#import "PLVInAppClientTypPanValidator.h"

#define ccPANNumberMinLength 12
#define ccPANNumberMaxLength 21

#define cardHolderMinLength 2
#define cardHolderMaxLength 26

#define cvvMinLength 3
#define cvvMaxLength 4


#define ddaccountNoMinLength 8
#define ddaccountNoMaxLength 10

#define ddroutingNoMinLength 5
#define ddroutingNoMaxLength 9

#define sepaIBANNumberMinLength 10
#define sepaIBANNumberMaxLength 34

#define sepaBICNumberLength1 8
#define sepaBICNumberLength2 11

#define paypalAuthTokenNumberMinLength 5
#define paypalAuthTokenNumberMaxLength 30



#define addError(validationErrors,errorCode,errorMessage) [validationErrors addObject:[NSError errorWithDomain:PLVAPIClientErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]]]

#define returnError(errorCode,errorMessage) return [NSError errorWithDomain:PLVAPIClientErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]]

@implementation PLVPaymentInstrumentValidator

+ (instancetype) validatorForPaymentInstrument:(PLVPaymentInstrument*)pi {
    
    if (pi == Nil) {
        return Nil;
    }
    
    if ([pi isKindOfClass:[PLVCreditCardPaymentInstrument class]]) {
        
        return [[PLVPayInstrumentCCValidator alloc] initWithPaymentInstrument:pi];
        
    } else if ([pi isKindOfClass:[PLVDebitCardPaymentInstrument class]]) {
        
        return [[PLVPayInstrumentDDValidator alloc] initWithPaymentInstrument:pi];
        
    } else if ([pi isKindOfClass:[PLVSEPAPaymentInstrument class]]) {
        
        return [[PLVPayInstrumentSEPAValidator alloc] initWithPaymentInstrument:pi];
        
    }else if ([pi isKindOfClass:[PLVPAYPALPaymentInstrument class]]) {
        
        return [[PLVPayInstrumentPAYPALValidator alloc] initWithPaymentInstrument:pi];
    }

    return Nil;
}

- (instancetype)initWithPaymentInstrument:(PLVPaymentInstrument*)paymentInstrument
{
    self = [super init];
    if (self) {
        _paymentInstrument = paymentInstrument;
    }
    return self;
}


- (NSArray*)  validateOnCreation {
    
    return Nil;
}

- (NSArray*) validateOnUpdate {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    if (self.paymentInstrument.identifier == Nil || self.paymentInstrument.identifier.length == 0) {
        addError(validationErrors,ERROR_INVALID_PAYMENTINSTRUMENTS_CODE,ERROR_INVALID_PAYMENTINSTRUMENTS_MESSAGE);
    }
    
//    if (self.paymentInstrument.sortIndex == Nil ) {
//        addError(validationErrors,ERROR_INVALID_PAYMENTINSTRUMENTS_CODE,ERROR_INVALID_PAYMENTINSTRUMENTS_MESSAGE);
//    }
    
    return validationErrors;
}

- (BOOL) containsOnlyValidCharctersAndDigits:(NSString*)valueToCheck {
    
    NSCharacterSet* nonDigits = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([valueToCheck rangeOfCharacterFromSet:nonDigits].location != NSNotFound)
    {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL) containsOnlyCharacters:(NSString*)valueToCheck {
    
    NSCharacterSet* nonCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    
    if ([valueToCheck rangeOfCharacterFromSet:nonCharacters].location != NSNotFound)
    {
        return FALSE;
    }
    
    return TRUE;
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

- (NSError*) validExpiryDateForMonth:(NSInteger)month andYear:(NSInteger)year {
    
    int yearInt = (int)year;
    int monthInt = (int)month;
    
    if (monthInt > 12 || monthInt < 1) {
        returnError(ERROR_DATE_MONTH_CODE,ERROR_DATE_MONTH_MESSAGE);
    }
    
    if (yearInt > 2050 || yearInt < 2010) {
        returnError(ERROR_DATE_YEAR_CODE,ERROR_DATE_YEAR_MESSAGE);
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    
    if ((yearInt < components.year) || ((yearInt == components.year) && (monthInt < components.month))) {
        returnError(ERROR_DATE_PASSED_CODE,ERROR_DATE_PASSES_MESSAGE);
    }
    
    return Nil;
}

@end


@interface PLVPayInstrumentCCValidator ()

@property (strong) PLVInAppClientTypPanValidator* validator;

@end



@implementation PLVPayInstrumentCCValidator

- (instancetype)initWithPaymentInstrument:(PLVCreditCardPaymentInstrument*)paymentInstrument
{
    self = [super init];
    if (self) {
        self.paymentInstrument = paymentInstrument;
    }
    return self;
}

- (NSArray*) validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    NSError* panError = [self validatePAN:self.paymentInstrument.pan];
    
    if (panError) {
        [validationErrors addObject:panError];
    }
    
    NSError* dateError = [self validateExpiryMonth:self.paymentInstrument.expiryMonth andYear:self.paymentInstrument.expiryYear];
    
    if (dateError) {
        [validationErrors addObject:dateError];
    }
    
    NSError* cvvError = [self validateCVV:self.paymentInstrument.cvv];
    
    if (cvvError) {
        [validationErrors addObject:cvvError];
    } else {
        // pan and cvv seem to be valid, we check cvv length
        
        if (self.paymentInstrument.cvv.length != [self.validator cvvlengthForPan:self.paymentInstrument.pan]) {
            addError(validationErrors,ERROR_CVV_INVALID_LENGTH_CODE,ERROR_CVV_INVALID_LENGTH_MESSAGE);
        }
    }
    
    NSError* cardHolderError = [self validateCardHolder:self.paymentInstrument.cardHolder];
    
    if (cardHolderError) {
        [validationErrors addObject:cardHolderError];
    }

    return validationErrors;
}

- (NSError*)validateExpiryMonth:(NSInteger)month andYear:(NSInteger)year {
    
    if (month == 0 || year == 0) {
        returnError(ERROR_DATE_EMPTY_CODE,ERROR_DATE_EMPTY_MESSAGE);
    }
        
    return [self validExpiryDateForMonth:month andYear:year];
}

- (NSError*)validatePAN:(NSString*)pan {
    
    if (self.validator == nil) {
        self.validator = [[PLVInAppClientTypPanValidator alloc] init];
    }
    
    if (pan == Nil || pan.length == 0 || pan.integerValue == 0) {
        returnError(ERROR_CC_EMPTY_CODE,ERROR_CC_EMPTY_MESSAGE);
    } else {
        
        if (pan.length < [self.validator minLengthForPan:pan]) {
            returnError(ERROR_CC_TOO_SHORT_CODE,ERROR_CC_TOO_SHORT_MESSAGE);
        }
        
        if (pan.length > [self.validator maxLengthForPan:pan]) {
            returnError(ERROR_CC_TOO_LONG_CODE,ERROR_CC_TOO_LONG_MESSAGE);
        }
        
        if (![self containsOnlyValidCharctersAndDigits:pan]) {
            returnError(ERROR_CC_INVALID_CHARS_CODE,ERROR_CC_INVALID_CHARS_MESSAGE);
        }

        if (![self containsOnlyDigits:pan]) {
            returnError(ERROR_CC_INVALID_CHARS_CODE,ERROR_CC_INVALID_CHARS_MESSAGE);
        }
        
        if ([self.validator doLuhnCheckForPan:pan]) {
            if (![self luhnCheck:pan]) {
                returnError(ERROR_CC_LUM_FAILED_CODE,ERROR_CC_LUM_FAILED_MESSAGE);
            }
        }
    }
    
    return Nil;
}

- (NSError*) validateCVV:(NSString*)cvv {
    
    if (cvv == Nil || cvv.length == 0) {
        returnError(ERROR_CVV_EMPTY_CODE,ERROR_CVV_EMPTY_MESSAGE);
    }
    
    if (![self containsOnlyDigits:cvv]) {
        returnError(ERROR_CVV_INVALID_CHARS_CODE,ERROR_CVV_INVALID_CHARS_MESSAGE);
    }
    
    if ((cvv.length < cvvMinLength) || (cvv.length > cvvMaxLength)) {
        returnError(ERROR_CVV_INVALID_LENGTH_CODE,ERROR_CVV_INVALID_LENGTH_MESSAGE);
    }
    
    return Nil;
}

- (NSError*) validateCardHolder:(NSString*)cardHolder {
    
    if (cardHolder == Nil || cardHolder.length == 0) {
        returnError(ERROR_CARDHOLDER_EMPTY_CODE,ERROR_CARDHOLDER_EMPTY_MESSAGE);
    }
    
    if (cardHolder.length < cardHolderMinLength || cardHolder.length > cardHolderMaxLength) {
        returnError(ERROR_CARDHOLDER_INVALID_LENGTH_CODE,ERROR_CARDHOLDER_INVALID_LENGTH_MESSAGE);
    }
    
    NSString* uppperCardHolder = [cardHolder uppercaseString];
    
    if ([uppperCardHolder rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ. "] invertedSet]].location != NSNotFound) {
        returnError(ERROR_CARDHOLDER_INVALID_CHARS_CODE,ERROR_CARDHOLDER_INVALID_CHARS_MESSAGE);
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


@implementation PLVPayInstrumentDDValidator

- (NSArray*) validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    NSError* accountNoError = [self validateAccountNo:self.paymentInstrument.accountNo];
    
    if (accountNoError) {
        [validationErrors addObject:accountNoError];
    }
    
    NSError* routingNoError = [self validateRoutingNo:self.paymentInstrument.routingNo];
    
    if (routingNoError) {
        [validationErrors addObject:routingNoError];
    }
    
    return validationErrors;
}

- (NSError*) validateAccountNo:(NSString*)accountNo {
    
    if (accountNo == Nil || accountNo.length == 0) {
        returnError(ERROR_DD_ACCOUNT_MISSING_CODE,ERROR_DD_ACCOUNT_MISSING_MESSAGE);
    } else {
        
        if (![self containsOnlyDigits:accountNo]) {
            returnError(ERROR_DD_ACCOUNT_INVALID_CHARS_CODE,ERROR_DD_ACCOUNT_INVALID_CHARS_MESSAGE);
        }
        
        if (accountNo.length < ddaccountNoMinLength) {
            returnError(ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE,ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE);
        }
        
        if (accountNo.length > ddaccountNoMaxLength) {
            returnError(ERROR_DD_ACCOUNT_INVALID_LENGTH_CODE,ERROR_DD_ACCOUNT_INVALID_LENGTH_MESSAGE);
        }
        
        if (accountNo.integerValue == 0) {
            returnError(ERROR_DD_ACCOUNT_MISSING_CODE,ERROR_DD_ACCOUNT_MISSING_MESSAGE);
        }
    }
    
    return Nil;
}

- (NSError*) validateRoutingNo:(NSString*)routingNo {

    if (routingNo == Nil || routingNo.length == 0 || routingNo.integerValue == 0) {
        returnError(ERROR_DD_ROUTING_MISSING_CODE,ERROR_DD_ROUTING_MISSING_MESSAGE);
    } else {

        if (![self containsOnlyDigits:routingNo]) {
            returnError(ERROR_DD_ROUTING_INVALID_CHARS_CODE,ERROR_DD_ROUTING_INVALID_CHARS_MESSAGE);
        }
        
        if (routingNo.length < ddroutingNoMinLength) {
            returnError(ERROR_DD_ROUTING_INVALID_LENGTH_CODE,ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE);
        }
        
        if (routingNo.length > ddroutingNoMaxLength) {
            returnError(ERROR_DD_ROUTING_INVALID_LENGTH_CODE,ERROR_DD_ROUTING_INVALID_LENGTH_MESSAGE);
        }
    }
    
    return Nil;
}

@end


@implementation PLVPayInstrumentSEPAValidator


- (NSArray*) validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    NSError* ibanError = [self validateIBAN:self.paymentInstrument.iban];
    
    if (ibanError) {
        [validationErrors addObject:ibanError];
    }
    
    if (self.paymentInstrument.bic == Nil || self.paymentInstrument.bic.length == 0) {
        
        // bic is optional
        
        return validationErrors;
    }
    
    // TODO add more BIC validations
    
    NSError* bicError = [self validateBIC:self.paymentInstrument.bic];
    
    if (bicError) {
        [validationErrors addObject:bicError];
    }
    
    return validationErrors;
}


- (NSError*) validateIBAN:(NSString*)iban {
    
    if (iban == Nil || iban.length == 0) {
        returnError(ERROR_SEPA_IBAN_EMPTY_CODE,ERROR_SEPA_IBAN_EMPTY_MESSAGE);
    } else {
        
        NSString* ibanToValidate = [iban stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (ibanToValidate.length < sepaIBANNumberMinLength || ibanToValidate.length > sepaIBANNumberMaxLength) {
            returnError(ERROR_SEPA_IBAN_INVALID_LENGTH_CODE,ERROR_SEPA_IBAN_INVALID_LENGTH_MESSAGE);
        } else {
            
            if ([ibanToValidate substringFromIndex:2].integerValue == 0) {
                returnError(ERROR_SEPA_IBAN_EMPTY_CODE,ERROR_SEPA_IBAN_EMPTY_MESSAGE);
            }
            
            if (![self containsDigits:[ibanToValidate substringToIndex:2]]) {
                returnError(ERROR_SEPA_IBAN_INVALID_CHARS_CODE,ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE);
            }
            
            if (![self containsOnlyDigits:[ibanToValidate substringWithRange:NSMakeRange(2, 2)]]) {
                returnError(ERROR_SEPA_IBAN_INVALID_CHARS_CODE,ERROR_SEPA_IBAN_INVALID_CHARS_MESSAGE);
            }
            
            if (![self checkIBAN:ibanToValidate]) {
                returnError(ERROR_SEPA_IBAN_INVALID_CODE,ERROR_SEPA_IBAN_INVALID_MESSAGE);
            }
        }
    }

    return Nil;
}

- (NSError*) validateBIC:(NSString*)bic {
    
    if ((bic.length != sepaBICNumberLength1) && (bic.length != sepaBICNumberLength2)) {
        
        returnError(ERROR_SEPA_BIC_INVALID_LENGTH_CODE,ERROR_SEPA_BIC_INVALID_LENGTH_MESSAGE);
    
    } else {
        
        NSString* bigBIC = [bic uppercaseString];
        
        if (![self containsOnlyCharacters:[bigBIC substringToIndex:6]]) {
            returnError(ERROR_SEPA_BIC_INVALID_CHARS_CODE,ERROR_SEPA_BIC_INVALID_CHARS_MESSAGE);
        }
        
        if (![self containsOnlyValidCharctersAndDigits:[bigBIC substringFromIndex:6]]) {
            returnError(ERROR_SEPA_BIC_INVALID_CHARS_CODE,ERROR_SEPA_BIC_INVALID_CHARS_MESSAGE);
        }
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

@implementation PLVPayInstrumentPAYPALValidator

- (NSArray*)   validateOnCreation {
    
    NSMutableArray* validationErrors = [NSMutableArray new];
    
    NSError* tokenError = [self validateAuthToken:self.paymentInstrument.authToken];
    
    if (tokenError) {
        [validationErrors addObject:tokenError];
    }
    
    return validationErrors;
}

- (NSError*) validateAuthToken:(NSString*)authToken {
    
    if (authToken == Nil || authToken.length == 0) {
        returnError(ERROR_PAYPAL_AUTH_TOKEN_EMPTY_CODE,ERROR_PAYPAL_AUTH_TOKEN_EMPTY_MESSAGE);
    } else {
        
        if (authToken.length < paypalAuthTokenNumberMinLength || authToken.length > paypalAuthTokenNumberMaxLength) {
            returnError(ERROR_PAYPAL_AUTH_TOKEN_INVALID_CODE,ERROR_PAYPAL_AUTH_TOKEN_INVALID_MESSAGE);
        }
        
        NSString* uppperAuthToken = [authToken uppercaseString];
        
        if ([uppperAuthToken rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ.0123456789 "] invertedSet]].location != NSNotFound) {
            returnError(ERROR_PAYPAL_AUTH_TOKEN_INVALID_CHARS_CODE,ERROR_PAYPAL_AUTH_TOKEN_INVALID_CHARS_MESSAGE);
        }
        
    }
    
    return Nil;
}

@end




