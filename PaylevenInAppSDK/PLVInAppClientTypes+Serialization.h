//
//  PLVInAppClientTypes.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 31.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVInAppClientTypes.h"

@interface PLVPaymentInstrument (Serialization)

+ (NSString*) piTypeForPLVPIType:(PLVPIType)type;
+ (instancetype) serializeWithDict:(NSDictionary*)dict;

- (NSDictionary*) piDictDescription;

@end

@interface PLVPayInstrumentCC (Serialization)



@end

@interface PLVPayInstrumentDD (Serialization)



@end

@interface PLVPayInstrumentSEPA (Serialization)



@end

@interface PLVPayInstrumentPAYPAL (Serialization)



@end