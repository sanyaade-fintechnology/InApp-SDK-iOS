//
//  AddPIViewController.h
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 10.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UseCaseViewController.h"

@interface AddPIViewController : UIViewController

@property (strong) NSString* userToken;
@property (strong) NSString* useCase;
@property (strong) NSString* emailAddress;

//to create a User Token you must create a payment instrument first
@property BOOL paymentInstrumentIsMandatory;

@end
