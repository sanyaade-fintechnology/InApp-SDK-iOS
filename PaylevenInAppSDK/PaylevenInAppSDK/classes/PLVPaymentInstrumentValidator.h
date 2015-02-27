//
//  PLVPaymentInstrumentValidator.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 31.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;

#import "PLVInAppClientTypes.h"


@interface PLVPaymentInstrumentValidator : NSObject

+ (instancetype) validatorForPaymentInstrument:(PLVPaymentInstrument*)pi;

@property (strong) PLVPaymentInstrument* paymentInstrument;

- (NSArray*) validateOnCreation;
- (NSArray*) validateOnUpdate;

@end


@interface PLVPayInstrumentCCValidator : PLVPaymentInstrumentValidator

@property (strong) PLVCreditCardPaymentInstrument* paymentInstrument;

- (NSError*)validateExpiryMonth:(NSInteger)month andYear:(NSInteger)year;
- (NSError*)validatePAN:(NSString*)pan;
- (NSError*)validateCVV:(NSString*)cvv;
- (NSError*)validateCardHolder:(NSString*)cardHolder;

@end


@interface PLVPayInstrumentDDValidator  : PLVPaymentInstrumentValidator

@property (strong) PLVDebitCardPaymentInstrument* paymentInstrument;

- (NSError*) validateAccountNo:(NSString*)accountNo;
- (NSError*) validateRoutingNo:(NSString*)routingNo;

@end


@interface PLVPayInstrumentSEPAValidator  : PLVPaymentInstrumentValidator

@property (strong) PLVSEPAPaymentInstrument* paymentInstrument;

- (NSError*) validateIBAN:(NSString*)iban;
- (NSError*) validateBIC:(NSString*)bic;

@end


@interface PLVPayInstrumentPAYPALValidator  : PLVPaymentInstrumentValidator

@property (strong) PLVPAYPALPaymentInstrument* paymentInstrument;

- (NSError*) validateAuthToken:(NSString*)authToken;

@end