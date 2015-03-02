//
//  AddUserTokenViewController.h
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 05.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UseCaseViewController.h"

@interface AddUserTokenViewController : UseCaseViewController

@property (strong) NSString* piTypeToCreate;
@property (strong) NSString* emailAddress;

@end
