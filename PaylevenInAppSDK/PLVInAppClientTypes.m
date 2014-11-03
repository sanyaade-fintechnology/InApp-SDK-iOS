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

@interface PLVPaymentInstrument()

@property (readwrite) PLVPIType type;

@end

@implementation PLVPaymentInstrument


- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = PLVPITypeUnknon;
    }
    return self;
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




