//
//  RootViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "RootViewController.h"


#import <PaylevenInAppSDK/PLVInAppSDK.h>

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@implementation RootViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.bundleIDLabel.text = [NSString stringWithFormat:@"BundleID: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]];
    
    self.registerAPIKeyButton.layer.cornerRadius = 10.f;
    self.registerAPIKeyButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.registerAPIKeyButton.layer.borderWidth = 1.f;
    
}


- (IBAction)showSelectAPIKeyActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the API Key"
                                                             delegate:self
                                                    cancelButtonTitle:(isIPAD ? Nil : @"Cancel")
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"nAj6Rensh2Ew3Oc4Ic2gig1F", @"4840bbc6429dacd56bfa98390ddf43", @"462123efc681534108cf2b34b4f8fb", nil];
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            self.apiKeyTextField.text = @"nAj6Rensh2Ew3Oc4Ic2gig1F";
            break;
        case 1:
            self.apiKeyTextField.text = @"4840bbc6429dacd56bfa98390ddf43";
            break;
        case 2:
            self.apiKeyTextField.text = @"462123efc681534108cf2b34b4f8fb";
            break;
        default:
            break;
    }
    
}


- (IBAction) setAPIKey:(id)sender {
    
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:self.apiKeyTextField.text];
    
    

}

@end
