//
//  PLVInAppSDKConstants.h
//  PaylevenInAppPayment
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef DEBUG
#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define SDLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define DLog(...) do { } while (0)
#define SDLog(...) do { } while (0)
#endif


#define piTypeKey               @"type"

#define ccExpiryMonthKey        @"expiryMonth"
#define ccExpiryYearKey         @"expiryYear"
#define ccPanKey                @"pan"
#define ccCCVKey                @"ccv"
#define ccBrandKey              @"cardBrand"

#define ddExpiryMonthKey        @"expiryMonth"
#define ddExpiryYearKey         @"expiryYear"
#define ddRoutingNumberKey      @"routingNo"
#define ddAccountNumberKey      @"accountNo"

#define sepaExpiryMonthKey      @"expiryMonth"
#define sepaExpiryYearKey       @"expiryYear"
#define sepaIBANNumberKey       @"iban"
#define sepaBICNumberKey        @"bic"

#define paypalAuthTokenKey      @"authToken"
#define paypalEmailAdressKey    @"email"

extern NSString * const kInAppSDKErrorDomain;
