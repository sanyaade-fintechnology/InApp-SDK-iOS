//
//  PaymentInstrumentValidation.m
//  PaylevenInAppSDKExample
//
//  Created by Johannes Rupieper on 25/08/15.
//  Copyright (c) 2015 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PaylevenInAppSDK/PLVInAppSDK.h>

@interface PaymentInstrumentValidation_Tests : XCTestCase

@end

@implementation PaymentInstrumentValidation_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark CVV validation

-(void)testValidatePaymentInstrumentWithCvvTooShort {
    //Tested with Visa
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"12"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * cvvError;
    [PLVCreditCardPaymentInstrument validateCVV:tempCC.cvv withError:&cvvError];
    
    if (cvvError.code == ERROR_CVV_INVALID_LENGTH_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithCvvTooLong {
    //Tested with Visa
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12234"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"12334"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * cvvError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateCVV:tempCC.cvv withError:&cvvError];
    
    if (cvvError.code == ERROR_CVV_INVALID_LENGTH_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithCvvMissing {
    //Tested with Visa
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12234"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@""
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * cvvError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateCVV:tempCC.cvv withError:&cvvError];
    
    if (cvvError.code == ERROR_CVV_EMPTY_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithCvvInvalidChars {
    //Tested with Visa
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12234"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"ölk"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * cvvError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateCVV:tempCC.cvv withError:&cvvError];
    
    if (cvvError.code == ERROR_CVV_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

#pragma mark PAN validation
-(void)testValidatePaymentInstrumentWithPANInvalidChars {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"424242asde24242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * panError;
    BOOL valid = [PLVCreditCardPaymentInstrument validatePan:tempCC.pan withError:&panError];
    
    if (panError.code == ERROR_CC_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithPANtooShort {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * panError;
    BOOL valid = [PLVCreditCardPaymentInstrument validatePan:tempCC.pan withError:&panError];
    
    if (panError.code == ERROR_CC_TOO_SHORT_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithPANtooLong {
    //Tested with Visa
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242424242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * panError;
    BOOL valid = [PLVCreditCardPaymentInstrument validatePan:tempCC.pan withError:&panError];
    
    if (panError.code == ERROR_CC_TOO_LONG_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithPANmissing {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@""
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * panError;
    BOOL valid = [PLVCreditCardPaymentInstrument validatePan:tempCC.pan withError:&panError];
    
    if (panError.code == ERROR_CC_EMPTY_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithPANwithWhiteSpaces {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"             "
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    NSError * panError;
    BOOL valid = [PLVCreditCardPaymentInstrument validatePan:tempCC.pan withError:&panError];
    
    if (panError.code == ERROR_CC_EMPTY_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

#pragma mark Cardholder validation

-(void)testValidatePaymentInstrumentWithCardholderInvalid {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"4929216008800817"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"%JOh)"];
    NSError * cardholderError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateCardHolder:tempCC.cardHolder withError:&cardholderError];
    
    if (cardholderError.code == ERROR_CARDHOLDER_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithCardholderInvalidContainsUnicodeChar {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"4929216008800817"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"Joh\U0001F31Eannes"];
    NSError * cardholderError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateCardHolder:tempCC.cardHolder withError:&cardholderError];
    
    if (cardholderError.code == ERROR_CARDHOLDER_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithCardholderTooShort {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * cardholderError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateCardHolder:tempCC.cardHolder withError:&cardholderError];
    
    if (cardholderError.code == ERROR_CARDHOLDER_INVALID_LENGTH_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

#pragma mark Exp Month validation
-(void)testValidatePaymentInstrumentWithExpiryMonthMissing {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@""
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expMonthError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryMonth:tempCC.expiryMonth withError:&expMonthError];
    
    if (expMonthError.code == ERROR_DATE_EMPTY_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryMonthStartingWithZeroes {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"005"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expMonthError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryMonth:tempCC.expiryMonth withError:&expMonthError];
    
    if (expMonthError.code == ERROR_DATE_MONTH_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryMonthInvalidAbove12 {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"13"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expMonthError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryMonth:tempCC.expiryMonth withError:&expMonthError];
    
    if (expMonthError.code == ERROR_DATE_MONTH_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryMonthInvalidBelow1 {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"0"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expMonthError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryMonth:tempCC.expiryMonth withError:&expMonthError];
    
    if (expMonthError.code == ERROR_DATE_EMPTY_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryMonthInvalidNegativeValue {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"-3"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expMonthError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryMonth:tempCC.expiryMonth withError:&expMonthError];
    
    if (expMonthError.code == ERROR_DATE_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryMonthInvalidChars {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"as"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expMonthError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryMonth:tempCC.expiryMonth withError:&expMonthError];
    
    if (expMonthError.code == ERROR_DATE_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

#pragma mark Exp Year validation
-(void)testValidatePaymentInstrumentWithExpiryYearMissing {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"2"
                                                                                                            expiryYear:@""
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expYearError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryYear:tempCC.expiryYear withError:&expYearError];
    
    if (expYearError.code == ERROR_DATE_EMPTY_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryYearTooShort {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"2"
                                                                                                            expiryYear:@"202"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expYearError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryYear:tempCC.expiryYear withError:&expYearError];
    
    if (expYearError.code == ERROR_DATE_YEAR_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryYearTooLong {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"2"
                                                                                                            expiryYear:@"20223"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expYearError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryYear:tempCC.expiryYear withError:&expYearError];
    
    if (expYearError.code == ERROR_DATE_YEAR_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

-(void)testValidatePaymentInstrumentWithExpiryYearContainsInvalidChars {
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"123456789012"
                                                                                                           expiryMonth:@"2"
                                                                                                            expiryYear:@"20l"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"J"];
    NSError * expYearError;
    BOOL valid = [PLVCreditCardPaymentInstrument validateExpiryYear:tempCC.expiryYear withError:&expYearError];
    
    if (expYearError.code == ERROR_DATE_INVALID_CHARS_CODE) {
        XCTAssert(true);
    }else{
        XCTFail(@"Validation Error Code incorrect");
    }
}

@end
