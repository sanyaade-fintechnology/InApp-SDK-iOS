//
//  PLVInAppClientTypes.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


#define     PLVPITypeUnknown    @"PLVPITypeUnknown"
#define     PLVPITypeCC         @"CC"
#define     PLVPITypeDD         @"DD"
#define     PLVPITypeSEPA       @"SEPA"
#define     PLVPITypePAYPAL     @"PAYPAL"


#define     PLVPIUseTypeDefault     @"DEFAULT"
#define     PLVPIUseTypePrivate     @"PRIVATE"
#define     PLVPIUseTypeBusiness    @"BUSINESS"
#define     PLVPIUseTypeBoth        @"BOTH"

@interface PLVPaymentInstrument : NSObject

@property (strong) NSString* identifier;
@property (strong) NSString* type;
@property (strong) NSString* useType;

@end

@interface PLVPayInstrumentCC : PLVPaymentInstrument

@property (strong) NSString* pan;
@property (readonly,nonatomic) NSString* cardBrand;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;
@property (strong) NSString* ccv;

@end

@interface PLVPayInstrumentDD : PLVPaymentInstrument

@property (strong) NSString* accountNumber;
@property (strong) NSString* routingNumber;
@end

@interface PLVPayInstrumentSEPA : PLVPaymentInstrument

@property (strong) NSString* iban;
@property (strong) NSString* bic;

@end

@interface PLVPayInstrumentPAYPAL : PLVPaymentInstrument

@property (strong) NSString* emailAddress;
@property (strong) NSString* oAuthToken;

@end