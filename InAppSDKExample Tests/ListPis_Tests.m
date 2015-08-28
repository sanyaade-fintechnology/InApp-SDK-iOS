//
//  ListPis_Tests.m
//  PaylevenInAppSDKExample
//
//  Created by Johannes Rupieper on 25/08/15.
//  Copyright (c) 2015 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PaylevenInAppSDK/PLVInAppSDK.h>

static int timeoutTolerance = 10;

@interface ListPis_Tests : XCTestCase

@end

@implementation ListPis_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:@"2c66f5fd510740ec83606bfe65bbdd26"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)addMultiplePaymentInstruments:(XCTestExpectation *)addPiExpectation {
    __weak ListPis_Tests *weakSelf = self;
    
    
    
    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"4344992206534013"
                                                                                                           expiryMonth:@"04"
                                                                                                            expiryYear:@"2019"
                                                                                                                   cvv:@"020"
                                                                                                         andCardHolder:@"iOS Dev"];
    
    
    
    [[PLVInAppClient sharedInstance] createUserToken:@"markus@gmail.de"   withPaymentInstrument:tempCC
                                       andCompletion:^(NSString *userToken, NSError *error) {
                                           
                                           if (error) {
                                               XCTFail(@"Test setup already failing....");
                                           } else {
                                               //weakSelf.userToken = userToken;
                                           }
                                           
                                       }];
    
    // 1. Create multiple CC PI's
    PLVCreditCardPaymentInstrument * tempCC_0 = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                             expiryMonth:@"12"
                                                                                                              expiryYear:@"2020"
                                                                                                                     cvv:@"123"
                                                                                                           andCardHolder:@"iOS Dev"];
    
    PLVCreditCardPaymentInstrument * tempCC_1 = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                             expiryMonth:@"12"
                                                                                                              expiryYear:@"2021"
                                                                                                                     cvv:@"123"
                                                                                                           andCardHolder:@"iOS Dev"];
    
    PLVCreditCardPaymentInstrument * tempCC_2 = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
                                                                                                             expiryMonth:@"12"
                                                                                                              expiryYear:@"2022"
                                                                                                                     cvv:@"123"
                                                                                                           andCardHolder:@"iOS Dev"];
        
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC
                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                            andCompletion:^(NSError *error) {
                                                if (error) {
                                                    XCTAssertNil(error, @"Not working...");
                                                } else {
//                                                    [addPiExpectation fulfill];
                                                }
                                            }];
    
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC_1
                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                            andCompletion:^(NSError *error) {
                                                if (error) {
                                                    XCTAssertNil(error, @"Not working...");
                                                } else {
//                                                    [addPiExpectation fulfill];
                                                }
                                            }];
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC_2
                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                            andCompletion:^(NSError *error) {
                                                if (error) {
                                                    XCTAssertNil(error, @"Not working...");
                                                } else {
                                                    [addPiExpectation fulfill];
                                                }
                                            }];
}

- (void)testAddingMultiplePaymentInstruments {
    
    XCTestExpectation * addPiOneExpectation = [self expectationWithDescription:@"Check adding multiple PI. 1"];
    XCTestExpectation * addPiTwoExpectation = [self expectationWithDescription:@"Check adding multiple PI. 2"];

    
    // 1. Create multiple CC PI's
    PLVCreditCardPaymentInstrument * tempCC_0 = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"5592760184670331"
                                                                                                             expiryMonth:@"12"
                                                                                                              expiryYear:@"2019"
                                                                                                                     cvv:@"159"
                                                                                                           andCardHolder:@"iOS Dev"];
    
    PLVCreditCardPaymentInstrument * tempCC_1 = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"5573610038655058"
                                                                                                             expiryMonth:@"06"
                                                                                                              expiryYear:@"2016"
                                                                                                                     cvv:@"354"
                                                                                                           andCardHolder:@"iOS Dev"];
    
    

    
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC_0
                                             forUserToken:@"e718eba759249b1047b10f83e786f9dea45eb477c638a565d23ff24bd1cca04c"
                                            andCompletion:^(NSError *error) {
                                                if (error) {
                                                    XCTAssertNil(error, @"Not working...");
                                                } else {
                                                    [addPiOneExpectation fulfill];
                                                }
                                            }];
    
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC_1
                                             forUserToken:@"e718eba759249b1047b10f83e786f9dea45eb477c638a565d23ff24bd1cca04c"
                                            andCompletion:^(NSError *error) {
                                                if (error) {
                                                    XCTAssertNil(error, @"Not working...");
                                                } else {
                                                    [addPiTwoExpectation fulfill];
                                                }
                                            }];
    

    [self waitForExpectationsWithTimeout:timeoutTolerance
                                 handler:^(NSError *error) {
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}

- (void)testListAllPaymentInstruments {
    
    XCTestExpectation * addPiExpectation = [self expectationWithDescription:@"List all payment instruments..."];
    
//    [self addMultiplePaymentInstruments:addPiExpectation];
    
//    PLVCreditCardPaymentInstrument * tempCC = [PLVCreditCardPaymentInstrument createCreditCardPaymentInstrumentWithPan:@"42424242424242"
//                                                                                                           expiryMonth:@"12"
//                                                                                                            expiryYear:@"2020"
//                                                                                                                   cvv:@"123"
//                                                                                                         andCardHolder:@"iOS Dev"];
//    
//    
//    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC
//                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
//                                            andCompletion:^(NSError *error) {
//                                                if (error) {
//                                                    XCTAssertNil(error, @"Not working...");
//                                                } else {
//                                                    [addPiExpectation fulfill];
//                                                }
//                                            }];
    

    

  
    [[PLVInAppClient sharedInstance] getPaymentInstrumentsList:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
                                                 andCompletion:^(NSArray *paymentInstrumentsArray, NSError *error) {
                                                     if (error) {
                                                         XCTAssertNil(error, @"");
                                                     }
                                                     
                                                     NSUInteger arraySize = paymentInstrumentsArray.count;
                                                     
                                                     if (arraySize > 0) {
                                                         [addPiExpectation fulfill];
                                                     }
                                                 }];
    
    [self waitForExpectationsWithTimeout:timeoutTolerance
                                 handler:^(NSError *error) {
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}


//- (void)testLater {
//    
//    [[PLVInAppClient sharedInstance] addPaymentInstrument:tempCC_0
//                                             forUserToken:@"f738293f15350c26aadae05463d647eafbf7806ef4ab0abeac704b0cd0b6ee8e"
//                                            andCompletion:^(NSError *error) {
//                                                if (error) {
//                                                    XCTFail(@"Not working...");
//                                                } else {
//                                                    [addPiExpectation fulfill];
//                                                }
//                                            }];
//    
//    [[PLVInAppClient sharedInstance] createUserToken:@"_______@gmail.hallo"   withPaymentInstrument:tempCC_0
//                                       andCompletion:^(NSString *userToken, NSError *error) {
//                                           if (error) {
//                                               XCTFail(@"Not working...");
//                                           }
//                                       }];
//}


@end
