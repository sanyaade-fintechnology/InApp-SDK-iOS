//
//  DetailViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 06.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "DetailViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface DetailViewController ()

@property (weak) IBOutlet UILabel* apiKeyLabel;
@property (weak) IBOutlet UITextField* emailTextField;
@property (weak) IBOutlet UIButton* getUserTokenButton;
@property (weak) IBOutlet UILabel* userTokenLabel;
@property (weak) IBOutlet UIView* activityPlane;
@property (weak) IBOutlet UIView* subPlane;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.getUserTokenButton.layer.cornerRadius = 10.f;
    self.getUserTokenButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.getUserTokenButton.layer.borderWidth = 1.f;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unregisterAPI:(id)sender {
    
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}



- (IBAction)showEmailActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the email address"
                                                             delegate:self
                                                    cancelButtonTitle:(isIPAD ? Nil : @"Cancel")
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"test@test.de", @"inAppSDK@payleven.de", @"mike@dummy.de", nil];
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            self.emailTextField.text = @"test@test.de";
            break;
        case 1:
            self.emailTextField.text = @"inAppSDK@payleven.de";
            break;
        case 2:
            self.emailTextField.text = @"mike@dummy.de";
            break;
        default:
            break;
    }
    
}

- (IBAction)editEmailField:(id)sender {
    
    
    
}

- (IBAction)getUserTokenAction:(id)sender {
    
    self.activityPlane.hidden = FALSE;
    
    [[PLVInAppClient sharedInstance] getUserToken:self.emailTextField.text withCompletion:^(NSDictionary* result, NSError* error){
        
        
        self.activityPlane.hidden = TRUE;
        
        if (error != Nil) {
            
            NSString* errorMessage = error.localizedDescription;
            
            if (errorMessage == Nil) {
                errorMessage = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"arghhh" otherButtonTitles:nil];
            
            [alertView show];
            
            
            self.subPlane.hidden = TRUE;
            
            self.userTokenLabel.text = @"";
            
        } else {
            
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                    
                    if ([result objectForKey:@"userToken"]) {
                        
                        self.subPlane.hidden = FALSE;
                        
                        self.userTokenLabel.text = [NSString stringWithFormat:@"UserToken: %@",[result objectForKey:@"userToken"]];
                        
                    }
                }
            }
            
        }
        
        
    }];
    
    
    
}

@end
