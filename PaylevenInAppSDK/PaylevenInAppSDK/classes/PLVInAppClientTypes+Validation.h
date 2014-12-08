//
//  PLVInAppClientTypes.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 31.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;

#import "PLVInAppClientTypes.h"


@interface PLVPaymentInstrument (Validation)

- (NSError*) validateOnCreation;
- (NSError*) validateOnUpdate;

@end

@interface PLVPayInstrumentCC (Validation)



@end

@interface PLVPayInstrumentDD (Validation)



@end

@interface PLVPayInstrumentSEPA (Validation)



@end

@interface PLVPayInstrumentPAYPAL (Validation)



@end