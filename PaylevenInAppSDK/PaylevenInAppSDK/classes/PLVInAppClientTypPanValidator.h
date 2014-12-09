//
//  PLVInAppClientTypes+PanValidation.h
//  PaylevenInAppSDK
//
//  Created by ploenne on 09.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVInAppClientTypes.h"

@interface PLVInAppClientTypPanValidator : NSObject

- (BOOL) doLuhnCheckForPan:(NSString*)pan;

@end
