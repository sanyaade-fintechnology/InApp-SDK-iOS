//
//  PLVCardBrands.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 01.12.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVCardBrands.h"


static NSString * const kCardBrandsJSONString = @"[{\"cardType\":\"DD\",\"id\":\"girocard\",\"iin_ranges\":[{\"end\":\"672\",\"start\":\"672\"}],\"aid_range\":[{\"starts_with\":\"A0000003591010028001\"},{\"starts_with\":\"A000000359\"}],\"name\":\"girocard\"},{\"cardType\":\"DD\",\"luhn_check\":true,\"pan_length_max\":19,\"id\":\"visa_electron\",\"pan_length_min\":16,\"aid_range\":[{\"starts_with\":\"A0000000032010\"}],\"name\":\"Visa Electron\"},{\"cardType\":\"DD\",\"luhn_check\":true,\"pan_length_max\":19,\"id\":\"visa_vpay\",\"iin_ranges\":[{\"end\":\"482\",\"start\":\"482\"}],\"pan_length_min\":16,\"aid_range\":[{\"starts_with\":\"A0000000032020\"},{\"starts_with\":\"A0000000031020\"}],\"name\":\"V PAY\"},{\"cardType\":\"CC\",\"luhn_check\":true,\"pan_length_max\":19,\"id\":\"visa_visa\",\"iin_ranges\":[{\"end\":\"4\",\"start\":\"4\"}],\"pan_length_min\":16,\"aid_range\":[{\"starts_with\":\"A0000000031010\"},{\"starts_with\":\"A0000000038010\"},{\"starts_with\":\"A000000003\"}],\"name\":\"Visa\"},{\"cardType\":\"DD\",\"luhn_check\":false,\"pan_length_max\":19,\"id\":\"mastercard_maestro\",\"iin_ranges\":[{\"end\":\"50\",\"start\":\"50\"},{\"end\":\"69\",\"start\":\"56\"}],\"pan_length_min\":12,\"aid_range\":[{\"starts_with\":\"A0000000043060\"},{\"starts_with\":\"A0000000050002\"}],\"name\":\"Maestro\"},{\"cardType\":\"DD\",\"luhn_check\":true,\"pan_length_max\":16,\"id\":\"mastercard_debit\",\"iin_ranges\":[{\"end\":\"557547\",\"start\":\"557498\"},{\"end\":\"557496\",\"start\":\"557347\"},{\"end\":\"537609\",\"start\":\"537210\"},{\"end\":\"535819\",\"start\":\"535420\"},{\"end\":\"535309\",\"start\":\"535110\"},{\"end\":\"517049\",\"start\":\"517000\"},{\"end\":\"516979\",\"start\":\"516730\"}],\"pan_length_min\":16,\"name\":\"Debit MasterCard\"},{\"cardType\":\"CC\",\"luhn_check\":true,\"pan_length_max\":16,\"id\":\"mastercard_mastercard\",\"iin_ranges\":[{\"end\":\"55\",\"start\":\"51\"},{\"end\":\"510510\",\"start\":\"510510\"}],\"pan_length_min\":16,\"aid_range\":[{\"starts_with\":\"A0000000049999\"},{\"starts_with\":\"A0000000046000\"},{\"starts_with\":\"A0000000050001\"},{\"starts_with\":\"A000000004\"}],\"name\":\"MasterCard\"},{\"cardType\":\"CC\",\"luhn_check\":true,\"pan_length_max\":16,\"id\":\"jcb\",\"iin_ranges\":[{\"end\":\"358999\",\"start\":\"352800\"}],\"pan_length_min\":16,\"aid_range\":[{\"starts_with\":\"A0000000651010\"},{\"starts_with\":\"A000000065\"}],\"name\":\"JCB\"},{\"cardType\":\"CC\",\"luhn_check\":true,\"pan_length_max\":16,\"id\":\"discover\",\"iin_ranges\":[{\"end\":\"659999\",\"start\":\"650000\"},{\"end\":\"649999\",\"start\":\"644000\"},{\"end\":\"601199\",\"start\":\"601186\"},{\"end\":\"601179\",\"start\":\"601177\"},{\"end\":\"601174\",\"start\":\"601174\"},{\"end\":\"601149\",\"start\":\"601120\"},{\"end\":\"601109\",\"start\":\"601100\"}],\"pan_length_min\":16,\"name\":\"Discover\"},{\"cardType\":\"CC\",\"luhn_check\":true,\"pan_length_max\":14,\"id\":\"diners\",\"iin_ranges\":[{\"end\":\"305\",\"start\":\"300\"},{\"end\":\"385\",\"start\":\"385\"},{\"end\":\"36\",\"start\":\"36\"}],\"pan_length_min\":14,\"name\":\"Diners\"},{\"cardType\":\"CC\",\"luhn_check\":true,\"pan_length_max\":15,\"id\":\"american_express\",\"iin_ranges\":[{\"end\":\"379999\",\"start\":\"370000\"},{\"end\":\"349999\",\"start\":\"340000\"},{\"mask\":\"37**9*******99*\"}],\"pan_length_min\":15,\"aid_range\":[{\"starts_with\":\"A00000002501\"},{\"starts_with\":\"A000000025\"}],\"name\":\"American Express\"}]";


@implementation PLVCardBrands

+ (NSArray *)cardBrands {
    static NSArray *cardBrands;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *JSONData = [kCardBrandsJSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        cardBrands = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
        if (cardBrands == nil) {
            NSLog(@"Error parsing card brands: %@", error);
        }
        if (![cardBrands isKindOfClass:[NSArray class]]) {
            NSLog(@"Card brands object is not an array");
            cardBrands = nil;
        }
    });
    
    return cardBrands;
}

@end
