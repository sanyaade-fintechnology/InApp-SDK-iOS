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

#define ccNumberMinLength 9
#define ccNumberMaxLength 21


#define CreateError(errorCode,errorMessage) [NSError errorWithDomain:PLVAPIClientErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedFailureReasonErrorKey]]

@implementation PLVPaymentInstrument (Validation)

//- (NSError*) validate {
//    
//    return Nil;
//}

- (BOOL) containsOnlyDigits:(NSString*)valueToCheck {

    NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if ([valueToCheck rangeOfCharacterFromSet:nonDigits].location != NSNotFound)
    {
        return FALSE;
    }
    
    return TRUE;
}

- (NSError*) validExpiryDateForMonth:(NSString*)month andYear:(NSString*)year {
    
    if (![self containsOnlyDigits:month] || ![self containsOnlyDigits:year]) {
        
        return CreateError(ERROR_DATE_INVALID_CHARS_CODE,ERROR_DATE_INVALID_CHARS_MESSAGE);
    }
    
    
    
    
    return Nil;
}

@end


@implementation PLVPayInstrumentCC (Validation)

- (NSError*) validate {
    
    if (self.pan == Nil || self.pan.length == 0) {
        return CreateError(ERROR_CC_EMPTY_CODE,ERROR_CC_EMPTY_MESSAGE);
    }
    
    if (self.pan.length < ccNumberMinLength) {
        return CreateError(ERROR_CC_TOO_SHORT_CODE,ERROR_CC_TOO_SHORT_MESSAGE);
    }
    
    if (self.pan.length > ccNumberMaxLength) {
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


@implementation PLVPayInstrumentDD (Serialization)

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    
    if (self.accountNumber != Nil) {
        [content setObject:self.accountNumber forKey:ddAccountNumberKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.routingNumber != Nil) {
        [content setObject:self.routingNumber forKey:ddRoutingNumberKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}

@end


@implementation PLVPayInstrumentSEPA (Serialization)


- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.bic != Nil) {
        [content setObject:self.bic forKey:sepaBICNumberKey];
    }
    
    if (self.iban != Nil) {
        [content setObject:self.iban forKey:sepaIBANNumberKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }

    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}


@end

@implementation PLVPayInstrumentPAYPAL (Serialization)

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.authToken != Nil) {
        [content setObject:self.authToken forKey:paypalAuthTokenKey];
    }

    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}

@end




