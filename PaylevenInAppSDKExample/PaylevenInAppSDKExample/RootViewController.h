//
//  RootViewController.h
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *bundleIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerAPIKeyButton;

@end

