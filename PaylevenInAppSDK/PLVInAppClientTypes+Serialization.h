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


- (NSString*) getJSONDescription:(NSMutableDictionary*)content;
- (NSString*) piDescription;

@end

@interface PLVPayInstrumentCC (Serialization)

- (NSString*) piDescription;

@end

@interface PLVPayInstrumentDD (Serialization)

- (NSString*) piDescription;

@end

@interface PLVPayInstrumentSEPA (Serialization)

- (NSString*) piDescription;

@end

@interface PLVPayInstrumentPAYPAL (Serialization)

- (NSString*) piDescription;

@end