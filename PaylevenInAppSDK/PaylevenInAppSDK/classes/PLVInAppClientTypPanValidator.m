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
@property (strong) NSDictionary* matchingInfoDict;
@property (strong) NSString* matchedPan;

@end

@implementation PLVInAppClientTypPanValidator


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _cardBrandInfos = [PLVCardBrands cardBrands];
        _matchingInfoDict = Nil;
        _matchedPan = Nil;
    }
    return self;
}


- (void) getMatchingDictForPan:(NSString*)pan {
    
    if ([pan isEqualToString:self.matchedPan] && self.matchingInfoDict != Nil ) {
        return;
    }
    
    self.matchingInfoDict = Nil;
    
    for (NSDictionary* dict in self.cardBrandInfos) {
        
        NSArray* ranges = [dict objectForKey:@"iin_ranges"];
        
        int rangeHitLength = 0;
        
        if (ranges != Nil) {
            
            for (NSDictionary* rangeDict in ranges) {
                
                NSString* start = [rangeDict objectForKey:@"start"];
                
                NSString* end = [rangeDict objectForKey:@"end"];
                
                if (start != nil && end != Nil) {
                    
                    if ((start.length == end.length) && (start.length > 0) && (start.length <= pan.length)) {
                        
                        long startValue = [[NSDecimalNumber decimalNumberWithString:start] longValue];
                        
                        long endValue = [[NSDecimalNumber decimalNumberWithString:end] longValue];
                        
                        long panValue = [[NSDecimalNumber decimalNumberWithString:[pan substringToIndex:start.length]] longValue];
                        
                        if (startValue <= panValue && panValue <= endValue) {
                            if (rangeHitLength < start.length) {
                                rangeHitLength = start.length;
                                self.matchingInfoDict = dict;
                                self.matchedPan = pan;
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

- (int) minLengthForPan:(NSString*)pan {
    
    [self getMatchingDictForPan:pan];
    
    if (self.matchingInfoDict != Nil) {
        
        NSNumber* panMinLength = [self.matchingInfoDict objectForKey:@"pan_length_min"];
        
        if (panMinLength != Nil) {
            return [panMinLength intValue];
        }
    }
    
    // otherwise return Default value
    
    return 12;
}

- (int) maxLengthForPan:(NSString*)pan {
    
    [self getMatchingDictForPan:pan];
    
    if (self.matchingInfoDict != Nil) {
        
        NSNumber* panMaxLength = [self.matchingInfoDict objectForKey:@"pan_length_max"];
        
        if (panMaxLength != Nil) {
            return [panMaxLength intValue];
        }
    }
    
    // otherwise return Default value
    
    return 21;
}

- (BOOL) doLuhnCheckForPan:(NSString*)pan {
    
    if(self.matchingInfoDict != Nil) {
    
        NSNumber* luhnCheck = [self.matchingInfoDict objectForKey:@"luhn_check"];
        
        if (luhnCheck != Nil) {
            return [luhnCheck boolValue];
        }
    }
    
    // otherwise return Default value
    
    return TRUE;
}

- (int) cvvlengthForPan:(NSString*)pan {
    
    if(self.matchingInfoDict != Nil) {
        
        NSString* brandName = [self.matchingInfoDict objectForKey:@"id"];
        
        if (brandName != Nil) {
            if([brandName isEqualToString:@"american_express"]) {
                return 4;
            }
        }
    }
    
    return 3;
}



@end
