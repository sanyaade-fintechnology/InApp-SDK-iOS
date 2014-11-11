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
        
        if ([piType isEqualToString:PLVPITypeCC]) {
            newPI = [[PLVPayInstrumentCC alloc] init];
        }
        if ([piType isEqualToString:PLVPITypeDD]) {
            newPI = [[PLVPayInstrumentDD alloc] init];
        }
        if ([piType isEqualToString:PLVPITypeSEPA]) {
            newPI = [[PLVPayInstrumentSEPA alloc] init];
        }
        if ([piType isEqualToString:PLVPITypePAYPAL]) {
            newPI = [[PLVPayInstrumentPAYPAL alloc] init];
        }
        
        SDLog(@"Serialze with Dict:%@",dict);
        
        [newPI initValuesWithDict:dict];
        
        return newPI;
    }
    
    return Nil;
    
}


- (NSString*) getJSONDescription:(NSMutableDictionary*)content {
    
    [content setObject:self.type forKey:piTypeKey];
    
    if (content == Nil || content.count == 0) {
        return @"{}";
    }
    NSError *JSONError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&JSONError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSMutableDictionary*) piDictDescription {
    
    NSMutableDictionary* content = [NSMutableDictionary new];
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    [content setObject:self.type forKey:piTypeKey];

    return content;
    
}

- (void) initValuesWithDict:(NSDictionary*)contentDict {
    
    [self setValuesForKeysWithDictionary:contentDict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    SDLog(@"Serialze %@: try to set undefinedKey:%@",[[self class] description],key);
    
}
@end


@implementation PLVPayInstrumentCC (Serialization)

- (NSDictionary*) piDictDescription {
    
    NSMutableDictionary* content = [super piDictDescription];
    
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
    
    return content;
}

@end


@implementation PLVPayInstrumentDD (Serialization)

- (NSDictionary*) piDictDescription {
    
    NSMutableDictionary* content = [super piDictDescription];
    
    if (self.accountNumber != Nil) {
        [content setObject:self.accountNumber forKey:ddAccountNumberKey];
    }
    
    if (self.routingNumber != Nil) {
        [content setObject:self.routingNumber forKey:ddRoutingNumberKey];
    }
    
    return content;
}

@end


@implementation PLVPayInstrumentSEPA (Serialization)


- (NSDictionary*) piDictDescription {
    
    NSMutableDictionary* content = [super piDictDescription];
    
    if (self.iban != Nil) {
        [content setObject:self.iban forKey:sepaIBANNumberKey];
    }
    
    if (self.bic != Nil) {
        [content setObject:self.bic forKey:sepaBICNumberKey];
    }
    
    return content;
}


@end

@implementation PLVPayInstrumentPAYPAL (Serialization)

- (NSDictionary*) piDictDescription {
    
    NSMutableDictionary* content = [super piDictDescription];
    
    if (self.oAuthToken != Nil) {
        [content setObject:self.oAuthToken forKey:paypalAuthTokenKey];
    }
    
    if (self.emailAddress != Nil) {
        [content setObject:self.emailAddress forKey:paypalEmailAdressKey];
    }
    
    return content;
}

@end




