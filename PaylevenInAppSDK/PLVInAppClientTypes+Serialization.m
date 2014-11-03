//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

#import "PLVInAppSDKConstants.h"
#import "PLVInAppClientTypes+Serialization.h"


@implementation PLVPaymentInstrument (Serialization)

+ (instancetype) serializeWithDict:(NSDictionary*)dict {
    
    if ([dict objectForKey:piTypeKey]) {
        
        NSString* piType = [dict objectForKey:piTypeKey];
        
        PLVPaymentInstrument* newPI;
        
        if ([piType isEqualToString:[PLVPaymentInstrument piTypeForPLVPIType:PLVPITypeCC]]) {
            newPI = [[PLVPayInstrumentCC alloc] init];
        }
        if ([piType isEqualToString:[PLVPaymentInstrument piTypeForPLVPIType:PLVPITypeDD]]) {
            newPI = [[PLVPayInstrumentDD alloc] init];
        }
        if ([piType isEqualToString:[PLVPaymentInstrument piTypeForPLVPIType:PLVPITypeSEPA]]) {
            newPI = [[PLVPayInstrumentSEPA alloc] init];
        }
        if ([piType isEqualToString:[PLVPaymentInstrument piTypeForPLVPIType:PLVPITypePAYPAL]]) {
            newPI = [[PLVPayInstrumentPAYPAL alloc] init];
        }
        
        [newPI initValuesWithDict:dict];
        
        return newPI;
    }
    
    return Nil;
    
}


- (NSString*) getJSONDescription:(NSMutableDictionary*)content {
    
    [content setObject:[PLVPaymentInstrument piTypeForPLVPIType:self.type] forKey:piTypeKey];
    
    if (content == Nil || content.count == 0) {
        return @"{}";
    }
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString*) piDescription {
    
    return @"";
    
}

- (void) initValuesWithDict:(NSDictionary*)contentDict {
    
    for (NSString* key in contentDict.allKeys) {
        
        [self setValue:[contentDict objectForKey:key] forKey:key];
    }
    
}

- (void) setValue:(id)value forKey:(NSString *)key {
    
    if ([self respondsToSelector:@selector(key)]) {
        [self performSelector:@selector(key) withObject:value];
    }
}

+ (NSString*) piTypeForPLVPIType:(PLVPIType)type {
    
    switch (type) {
        case PLVPITypeCC:
            return @"CC";
            break;
        case PLVPITypeDD:
            return @"DD";
            break;
        case PLVPITypeSEPA:
            return @"SEPA";
            break;
        case PLVPITypePAYPAL:
            return @"PAYPAL";
            break;
        default:
            return @"UNKOWN";
    }
}

@end


@implementation PLVPayInstrumentCC (Serialization)

- (NSString*) piDescription {
    
    NSMutableDictionary* content = [NSMutableDictionary new];
    
    if (self.pan != Nil) {
        [content setObject:self.pan forKey:ccPanKey];
    }
    
    if (self.expiryMonth != Nil) {
        [content setObject:self.expiryMonth forKey:ccExpiryMonthKey];
    }
    
    if (self.expiryYear != Nil) {
        [content setObject:self.expiryYear forKey:ccExpiryYearKey];
    }
    
    if (self.ccv != Nil) {
        [content setObject:self.ccv forKey:ccCCVKey];
    }
    
    return [super getJSONDescription:content];
}


- (void) initValuesWithDict:(NSDictionary*)dict {
    
    
    for (NSString* key in dict.allKeys) {
        
        [self setValue:[dict objectForKey:key] forKey:key];
    }

}

@end


@implementation PLVPayInstrumentDD (Serialization)

- (NSString*) piDescription {
    
    NSMutableDictionary* content = [NSMutableDictionary new];
    
    if (self.expiryMonth != Nil) {
        [content setObject:self.expiryMonth forKey:ddExpiryMonthKey];
    }
    
    if (self.expiryYear != Nil) {
        [content setObject:self.expiryYear forKey:ddExpiryYearKey];
    }
    
    if (self.accountNumber != Nil) {
        [content setObject:self.accountNumber forKey:ddAccountNumberKey];
    }
    
    if (self.routingNumber != Nil) {
        [content setObject:self.routingNumber forKey:ddRoutingNumberKey];
    }
    
    return [super getJSONDescription:content];
}

@end


@implementation PLVPayInstrumentSEPA (Serialization)


- (NSString*) piDescription {
    
    NSMutableDictionary* content = [NSMutableDictionary new];
    
    if (self.expiryMonth != Nil) {
        [content setObject:self.expiryMonth forKey:sepaExpiryMonthKey];
    }
    
    if (self.expiryYear != Nil) {
        [content setObject:self.expiryYear forKey:sepaExpiryYearKey];
    }
    
    if (self.iban != Nil) {
        [content setObject:self.iban forKey:sepaIBANNumberKey];
    }
    
    if (self.bic != Nil) {
        [content setObject:self.bic forKey:sepaBICNumberKey];
    }
    
    return [super getJSONDescription:content];
}


@end


@implementation PLVPayInstrumentPAYPAL (Serialization)

- (NSString*) piDescription {
    
    NSMutableDictionary* content = [NSMutableDictionary new];
    
    if (self.oAuthToken != Nil) {
        [content setObject:self.oAuthToken forKey:paypalAuthTokenKey];
    }
    
    if (self.emailAddress != Nil) {
        [content setObject:self.emailAddress forKey:paypalEmailAdressKey];
    }
    
    return [super getJSONDescription:content];
}

@end




