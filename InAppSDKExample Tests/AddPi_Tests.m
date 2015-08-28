//
//  AddPiTests.m
//  PaylevenInAppSDKExample
//
//  Created by Johannes Rupieper on 25/08/15.
//  Copyright (c) 2015 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PaylevenInAppSDK/PLVInAppSDK.h>

static int timeoutTolerance = 10;

@interface AddPi_Tests : XCTestCase

@end

@implementation AddPi_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:@"2c66f5fd510740ec83606bfe65bbdd26"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testAddPaymentInstrumentWithValidData {
    XCTestExpectation * addPiExpectation = [self expectationWithDescription:@"Add PI"];
    
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"5592760184670331"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2019"
                                                                                                                   cvv:@"159"
                                                                                                         andCardHolder:@"iOS Dev"];
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC
                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                            andCompletion:^(NSError *error) {
                                                if (!error) {
                                                    [addPiExpectation fulfill];
                                                }else{
                                                    XCTFail(@"Method Error: %@", error);
                                                }
                                            }];
    
    [self waitForExpectationsWithTimeout:timeoutTolerance
                                 handler:^(NSError *error) {
                                     // handler is called on _either_ success or failure
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}

//We need to see 8600 ERROR_INVALID_PAYMENTINSTRUMENTS_CODE
-(void)testAddPaymentInstrumentWithCvvTooShort {
    XCTestExpectation * addPiExpectation = [self expectationWithDescription:@"Add PI with CVV too short"];
    
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"12"
                                                                                                         andCardHolder:@"iOS Dev"];
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC
                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                            andCompletion:^(NSError *error) {
                                                if (error.code == ERROR_INVALID_PAYMENTINSTRUMENTS_CODE) {
                                                    [addPiExpectation fulfill];
                                                }else{
                                                    XCTFail(@"Wrong BE error code: %@", error);
                                                }
                                                
                                            }];
    
    [self waitForExpectationsWithTimeout:timeoutTolerance
                                 handler:^(NSError *error) {
                                     // handler is called on _either_ success or failure
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}

-(void)testAddPaymentInstrumentValidUntilThisMonth{
    XCTestExpectation * addPiThatWillExpireThisMonth = [self expectationWithDescription:@"Add PI CC that will expire today"];
    
    NSDate * today = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];

    NSInteger monthInt = [components month];
    NSInteger yearInt = [components year];
    
    NSString * month = [NSString stringWithFormat:@"%ld",(long)monthInt];
    NSString * year = [NSString stringWithFormat:@"%ld",(long)yearInt];
    
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"5336288998604339"
                                                                                                           expiryMonth:month
                                                                                                            expiryYear:year
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC
                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                            andCompletion:^(NSError *error) {
                                                if (!error) {
                                                    [addPiThatWillExpireThisMonth fulfill];
                                                }else{
                                                    XCTFail(@"Add PI that will expire this month failed: %@", error);
                                                }
                                                
                                            }];

    
    [self waitForExpectationsWithTimeout:timeoutTolerance
                                 handler:^(NSError *error) {
                                     // handler is called on _either_ success or failure
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}


@end
