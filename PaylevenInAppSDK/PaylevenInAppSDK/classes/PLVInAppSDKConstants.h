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

#define plvInAppSDKResponseStatusKey @"status"
#define plvInAppSDKResponseResultKey @"response"

#define plvInAppSDKResponseDescriptionKey @"description"
#define plvInAppSDKResponseCodeKey @"code"

#define plvInAppSDKStatusOK @"OK"
#define plvInAppSDKStatusKO @"KO"

#define piIdentifierTypeKey     @"identifier"
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

#define PLVAPIClientErrorDomain @"PLVAPIClientErrorDomain"
#define PLVAPIBackEndErrorDomain @"PLVAPIBackEndErrorDomain"


#define ERROR_INVALID_BACKEND_RESPONSE_CODE 8000
#define ERROR_INVALID_BACKEND_RESPONSE_MESSAGE @"INVALID BACKEND RESPONSE"

#define ERROR_MISSING_API_KEY_CODE 8100
#define ERROR_MISSING_API_KEY_MESSAGE @"MISSING API KEY"

#define ERROR_MISSING_CALLBACK_CODE 8200
#define ERROR_MISSING_CALLBACK_MESSAGE @"MISSING CALLBACK"

#define ERROR_MISSING_EMAILADDRESS_CODE 8300
#define ERROR_MISSING_EMAILADDRESS_MESSAGE @"MISSING EMAILADDRESS"

#define ERROR_MISSING_USERTOKEN_CODE 8400
#define ERROR_MISSING_USERTOKEN_MESSAGE @"MISSING_USERTOKEN"

#define ERROR_MISSING_PAYMENTINSTRUMENTS_CODE 8500
#define ERROR_MISSING_PAYMENTINSTRUMENTS_MESSAGE   @"MISSING PAYMENTINSTRUMENTS"


