//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//



#import "PLVInAppClientTypes.h"
#import "PLVInAppSDKConstants.h"

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


@interface PLVPaymentInstrument()

@property (readwrite) NSString* sortIndex;
@property (readwrite) NSString* identifier;

@end

@implementation PLVPaymentInstrument

@synthesize type = _type;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = PLVPICCTypeUnknown;
        _identifier = @"";
    }
    return self;
}

@end

@interface PLVPayInstrumentCC ()

@end

@implementation PLVPayInstrumentCC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeCC;
        self.pan = @"";
        _expiryYear = @"";
        _expiryMonth = @"";
        _cvv = @"";
        _cardBrand = @"";
    }
    return self;
}

@end


@implementation PLVPayInstrumentDD

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeDD;
        self.routingNumber = @"";
        self.accountNumber = @"";
    }
    return self;
}

@end


@implementation PLVPayInstrumentSEPA

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeSEPA;
        self.iban = @"";
        self.bic = @"";
    }
    return self;
}

@end


@implementation PLVPayInstrumentPAYPAL

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = PLVPITypePAYPAL;
        self.authToken = @"";
    }
    return self;
}

@end




