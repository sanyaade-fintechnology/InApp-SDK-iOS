//
//  RootViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "RootViewController.h"

#import <PaylevenInAppSDK/PLVInAppSDK.h>


#define kUserDefaultsBEIPKey @"backEndIP"

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface RootViewController()

@property (strong) NSString* savedBEIP;
@property (weak) IBOutlet UITextField* backEndIPTextField;
@property (weak) IBOutlet UIButton* resetButton;

@end


@implementation RootViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.savedBEIP = Nil;
    
    [self loadBackEndIP];
    
    if (self.savedBEIP != Nil) {
        self.backEndIPTextField.text = self.savedBEIP;
    }
    
    self.bundleIDLabel.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build: %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    self.registerAPIKeyButton.layer.cornerRadius = 5.f;
    self.registerAPIKeyButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.registerAPIKeyButton.layer.borderWidth = 1.f;
}

- (IBAction)longPress:(id)sender {

    self.savedBEIP = Nil;
    self.backEndIPTextField.text = @"Default";
    self.apiKeyTextField.text = @"4840bbc6429dacd56bfa98390ddf43";

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
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:self.apiKeyTextField.text andSpecificBaseServiceURL: self.savedBEIP];
    
}


- (void) loadBackEndIP {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBEIPKey] isKindOfClass:[NSString class]]) {
        
        self.savedBEIP = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBEIPKey];
    
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length > 3) {
        
        self.savedBEIP = textField.text;
        
        if (![self.savedBEIP hasPrefix:@"http://"]) {
            self.savedBEIP = [NSString stringWithFormat:@"http://%@",self.savedBEIP];
        }
        
        
        if (![self.savedBEIP hasSuffix:@"/staging/api"]) {
            self.savedBEIP = [NSString stringWithFormat:@"%@/staging/api",self.savedBEIP];
        }
        
        
        textField.text = self.savedBEIP;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.savedBEIP forKey:kUserDefaultsBEIPKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [textField resignFirstResponder];
    
    return TRUE;
}

@end
