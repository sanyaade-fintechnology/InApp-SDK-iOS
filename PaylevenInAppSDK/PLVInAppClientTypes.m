//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;

#import "PLVInAppClientTypes.h"

@interface PLVPITypeBase()

@property (readwrite) PLVPIType type;
@property (readwrite) NSString* description;

@end

@implementation PLVPITypeBase


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
        super.type = PLVPITypeCC;
    }
    return self;
}

@end


@implementation PLVPayInstrumentDD

- (instancetype)init
{
    self = [super init];
    if (self) {
        super.type = PLVPITypeDD;
    }
    return self;
}

@end


@implementation PLVPayInstrumentSEPA

- (instancetype)init
{
    self = [super init];
    if (self) {
        super.type = PLVPITypeSEPA;
    }
    return self;
}

@end


@implementation PLVPayInstrumentPAYPAL

- (instancetype)init
{
    self = [super init];
    if (self) {
        super.type = PLVPITypePAYPAL;
    }
    return self;
}

@end


