//
//  DetailViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 06.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserTokenDetailViewController.h"
#import "PayInstTableViewController.h"
#import "AddPIViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>
#import "MBProgressHUD.h"

@interface UserTokenDetailViewController ()

@property (weak) IBOutlet UITextField* userTokenTextField;
@property (weak) IBOutlet UITextField* emailTextField;

@property (weak) IBOutlet UIButton* backButton;

@property (weak) IBOutlet UIButton* addPIButton;
@property (weak) IBOutlet UIButton* listPIButton;

@end

@implementation UserTokenDetailViewController

#pragma mark Lifecycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.userTokenTextField.text = self.userToken;
    self.emailTextField.text = self.emailAddress;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueIdentifier = segue.identifier;
    
    if ([segueIdentifier isEqualToString:@"AddPISegue"]) {
        
        AddPIViewController* addPiVC = [segue destinationViewController];
        addPiVC.userToken = self.userTokenTextField.text;
        
    }else if ([segueIdentifier isEqualToString:@"ListPIsSegue"]){
        
        PayInstTableViewController* listVC = [segue destinationViewController];
        listVC.userToken = self.userTokenTextField.text;
        
    }
}

#pragma mark IBAction Methods

- (IBAction)backToRegisterPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark UITextField Delegate methods

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}



@end
