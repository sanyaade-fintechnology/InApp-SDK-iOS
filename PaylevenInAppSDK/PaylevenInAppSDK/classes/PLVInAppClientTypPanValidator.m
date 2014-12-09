//
//  PLVInAppClientTypPanValidator.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 09.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVInAppClientTypPanValidator.h"
#import "PLVCardBrands.h"

@interface PLVInAppClientTypPanValidator ()

@property (strong) NSArray* cardBrandInfos;

@end

@implementation PLVInAppClientTypPanValidator


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _cardBrandInfos = [PLVCardBrands cardBrands];
    }
    return self;
}

- (BOOL) doLuhnCheckForPan:(NSString*)pan {
    


    return TRUE;
}

@end
