//
//  PLVHTTPUserAgent.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 07/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVHTTPUserAgent.h"

@import UIKit;

@implementation PLVHTTPUserAgent

+ (NSString *)userAgentString {
    UIDevice *device = [UIDevice currentDevice];
    NSLocale *locale = [NSLocale currentLocale];
    NSDictionary *localeComponents = [NSLocale componentsFromLocaleIdentifier:locale.localeIdentifier];
    
    return [NSString stringWithFormat:@"Payleven-mPOS-SDK/%@ iOS/%@ (%@; %@-%@)",
            @"1.0", device.systemVersion, device.model,
            localeComponents[NSLocaleLanguageCode], localeComponents[NSLocaleCountryCode]];
}

@end
