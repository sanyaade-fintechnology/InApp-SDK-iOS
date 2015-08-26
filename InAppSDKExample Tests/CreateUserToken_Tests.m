//
//  CreateUserToken_Tests.m
//  PaylevenInAppSDKExample
//
//  Created by Johannes Rupieper on 25/08/15.
//  Copyright (c) 2015 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PaylevenInAppSDK/PLVInAppSDK.h>

static int timeoutTolerance = 10;

@interface CreateUserToken_Tests : XCTestCase

@end

@implementation CreateUserToken_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:@"2c66f5fd510740ec83606bfe65bbdd26"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testCreateUserToken {
    
    XCTestExpectation *createUserTokenExpectation = [self expectationWithDescription:@"Create user token."];
    
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    
    NSUUID * uuid = [NSUUID UUID];
    NSString *uniqueMail = [NSString stringWithFormat:@"%@@iOS-UnitTest.de", [uuid UUIDString]];

    [[PLVInAppClient sharedInstance] createUserToken:uniqueMail
                               withPaymentInstrument:tempCC
                                       andCompletion:^(NSString *userToken, NSError *error) {
                                           
                                           if (error) {
                                               XCTFail(@"error thrown...");
                                           }
                                           
                                           if (userToken && userToken.length>0) {
                                               [createUserTokenExpectation fulfill];
                                           } else {
                                               XCTFail(@"Fail due to nil or empty user token.");
                                           }
    }];
    
    
    
    [self waitForExpectationsWithTimeout:timeoutTolerance handler:^(NSError *error) {
        // handler is called on _either_ success or failure
        if (error != nil) {
            XCTFail(@"timeout error: %@", error);
        }
    }];
    
}

-(void)testCreateUserTokenWithInvalidApiKey{
    XCTestExpectation * createUserTokenExpectation = [self expectationWithDescription:@"Create UT with invalid API Key"];
    
    [[PLVInAppClient sharedInstance]registerWithAPIKey:@"some Bullshit API Key"];
    
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                           expiryMonth:@"12"
                                                                                                            expiryYear:@"2020"
                                                                                                                   cvv:@"123"
                                                                                                         andCardHolder:@"iOS Dev"];
    
    NSString * uniqueMail = [NSString stringWithFormat:@"%@@iOS-UnitTest.de",[NSUUID UUID]];
    
    [[PLVInAppClient sharedInstance] createUserToken:uniqueMail
                               withPaymentInstrument:tempCC
                                       andCompletion:^(NSString *userToken, NSError *error) {
                                           
                                           if (error) {
                                               //we expect an error here! Remember we have a non-valid API Key
                                               [createUserTokenExpectation fulfill];
                                           }else{
                                               XCTFail(@"Error, we have an invalid API Key but can create a Usertoken!");
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
