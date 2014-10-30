//
//  PLVInAppClientTypes.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

typedef enum : NSUInteger {
    PLVPITypeUnknon = 0,
    PLVPITypeCC,
    PLVPITypeDD,
    PLVPITypeSEPA,
    PLVPITypePAYPAL
} PLVPIType;


typedef enum : NSUInteger {
    PLVPICCTypeUnknown = 0,
    PLVPICCTypeVISA,
    PLVPICCTypeVISA_ELECTRON,
    PLVPICCTypeVPAY,
    PLVPICCTypeAMEX,
    PLVPICCTypeDINERS,
    PLVPICCTypeOTHER
} PLVPICCType;


@interface PLVPITypeBase : NSObject

@property (strong, readonly) NSString* identifier;
@property (readonly) PLVPIType type;
@property (readonly) NSString* description;

@end

@interface PLVPayInstrumentCC : PLVPITypeBase

@property (strong) NSString* pan;
@property (readonly,nonatomic) PLVPICCType cardBrand;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;
@property (strong) NSString* ccv;

@end

@interface PLVPayInstrumentDD : PLVPITypeBase

@property (strong) NSString* accountNo;
@property (strong) NSString* routingNo;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;
@end

@interface PLVPayInstrumentSEPA : PLVPITypeBase

@property (strong) NSString* IBAN;
@property (strong) NSString* BIC;
@property (strong) NSString* expiryMonth;
@property (strong) NSString* expiryYear;

@end

@interface PLVPayInstrumentPAYPAL : PLVPITypeBase

@property (strong) NSString* emailAddress;
@property (strong) NSString* oAuthToken;

@end