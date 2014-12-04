//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVInAppSDKConstants.h"
#import "PLVInAppClientTypes.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "OrderedDictionary.h"

@implementation PLVPaymentInstrument (Serialization)

+ (instancetype) serializeWithDict:(NSDictionary*)dict {
    
    if ([dict objectForKey:piTypeKey]) {
        
        NSString* piType = [dict objectForKey:piTypeKey];
        
        PLVPaymentInstrument* newPI;
        
        if ([piType isEqualToString:PLVPITypeCC]) {
            newPI = [[PLVPayInstrumentCC alloc] init];
        } else if ([piType isEqualToString:PLVPITypeDD]) {
            newPI = [[PLVPayInstrumentDD alloc] init];
        } else if ([piType isEqualToString:PLVPITypeSEPA]) {
            newPI = [[PLVPayInstrumentSEPA alloc] init];
        } else if ([piType isEqualToString:PLVPITypePAYPAL]) {
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
    
    OrderedDictionary* content = [OrderedDictionary new];
    
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
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.cvv != Nil) {
        [content setObject:self.cvv forKey:ccCVVKey];
    }
    
    if (self.expiryMonth != Nil) {
        [content setObject:self.expiryMonth forKey:ccExpiryMonthKey];
    }
    
    if (self.expiryYear != Nil) {
        [content setObject:self.expiryYear forKey:ccExpiryYearKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.pan != Nil) {
        [content setObject:self.pan forKey:ccPanKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}

@end


@implementation PLVPayInstrumentDD (Serialization)

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    
    if (self.accountNumber != Nil) {
        [content setObject:self.accountNumber forKey:ddAccountNumberKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.routingNumber != Nil) {
        [content setObject:self.routingNumber forKey:ddRoutingNumberKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}

@end


@implementation PLVPayInstrumentSEPA (Serialization)


- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.bic != Nil) {
        [content setObject:self.bic forKey:sepaBICNumberKey];
    }
    
    if (self.iban != Nil) {
        [content setObject:self.iban forKey:sepaIBANNumberKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }

    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}


@end

@implementation PLVPayInstrumentPAYPAL (Serialization)

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.authToken != Nil) {
        [content setObject:self.authToken forKey:paypalAuthTokenKey];
    }

    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}

@end




