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

typedef NSString PLVPIType;

typedef enum : NSUInteger {
    PLVPICCTypeUnknown = 0,
    PLVPICCTypeVISA,
    PLVPICCTypeVISA_ELECTRON,
    PLVPICCTypeVPAY,
    PLVPICCTypeAMEX,
    PLVPICCTypeDINERS,
    PLVPICCTypeOTHER
} PLVPICCType;


@interface PLVPaymentInstrument : NSObject

@property (strong) NSString* identifier;
@property (strong) NSString* type;

@end

@interface PLVPayInstrumentCC : PLVPaymentInstrument

@property (strong) NSString* pan;
@property (readonly,nonatomic) PLVPICCType cardBrand;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;
@property (strong) NSString* ccv;

@end

@interface PLVPayInstrumentDD : PLVPaymentInstrument

@property (strong) NSString* accountNumber;
@property (strong) NSString* routingNumber;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;
@end

@interface PLVPayInstrumentSEPA : PLVPaymentInstrument

@property (strong) NSString* iban;
@property (strong) NSString* bic;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;

@end

@interface PLVPayInstrumentPAYPAL : PLVPaymentInstrument

@property (strong) NSString* emailAddress;
@property (strong) NSString* oAuthToken;

@end