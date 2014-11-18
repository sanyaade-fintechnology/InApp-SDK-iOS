//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

@import Foundation;

#import "PLVInAppSDKConstants.h"
#import "PLVInAppErrors.h"
#import "PLVInAppClientTypes.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "OrderedDictionary.h"

#define ccNumberMinLength 9
#define ccNumberMaxLength 9


#define CreateError(errorCode,errorMessage) [NSError errorWithDomain:PLVAPIClientErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedFailureReasonErrorKey]]

@implementation PLVPaymentInstrument (Validation)

- (NSError*) validate {
    
    return Nil;
}


@end


@implementation PLVPayInstrumentCC (Validation)

- (NSError*) validate {
    
    if (self.pan == Nil || self.pan.length == 0) {
        return CreateError(ERROR_CC_EMPTY_CODE,ERROR_CC_EMPTY_MESSAGE);
    }
    
    if (self.pan.length < ccNumberMinLength) {
        return CreateError(ERROR_CC_TOO_SHORT_CODE,ERROR_CC_TOO_SHORT_MESSAGE);
    }
    
    if (self.pan.length > ccNumberMaxLength) {
        return CreateError(ERROR_CC_TOO_LONG_CODE,ERROR_CC_TOO_LONG_MESSAGE);
    }
    
    return Nil;
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




