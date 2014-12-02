//
//  UIDevice+Platform.h
//  Payleven
//
//  Created by Jonas Stubenrauch on 31.10.12.
//  Copyright (c) 2012 payleven Holding GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Platform)

@property (nonatomic, strong, readonly) NSString *platform;
@property (nonatomic, strong, readonly) NSString *platformString;

@end
