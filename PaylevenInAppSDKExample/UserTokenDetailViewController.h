//
//  DetailViewController.h
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 06.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UseCaseViewController.h"

@interface UserTokenDetailViewController : UseCaseViewController

@property (strong) NSString* userToken;
@property (strong) NSString* emailAddress;

@end
