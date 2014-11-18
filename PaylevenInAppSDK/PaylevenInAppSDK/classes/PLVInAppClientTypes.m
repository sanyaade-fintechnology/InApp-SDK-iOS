//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

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

@end

@implementation PLVPaymentInstrument

@synthesize type = _type;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = PLVPICCTypeUnknown;
    }
    return self;
}

- (NSError*) errorWithCode:(NSInteger)codeNumber andDescription:(NSString*)errorDescription {
    return [NSError errorWithDomain:PLVAPIClientErrorDomain code:codeNumber userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:NSLocalizedFailureReasonErrorKey]];
}

@end


@implementation PLVPayInstrumentCC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeCC;
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
    }
    return self;
}

@end




