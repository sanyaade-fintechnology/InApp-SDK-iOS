//
//  RootViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;

//Integration-Task-1: Import Payleven SDK
#import <PaylevenInAppSDK/PLVInAppSDK.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "RegisterViewController.h"
#import "AddPIViewController.h"
#import "UserTokenDetailViewController.h"

#define kUserDefaultsUserTokenPKey @"userToken"
#define kUserDefaultsMailAddressKey @"mailAddress"
#define kUserDefaultsCurrentUseCaseKey @"currentUseCase"
#define kUserDefaultsAllUseCasesKey @"allUseCase"

@interface RegisterViewController() <UIActionSheetDelegate>

@property (weak) IBOutlet UITextField* userTokenTextField;
@property (weak) IBOutlet UITextField* emailTextField;

@property (weak) IBOutlet UIButton* resetAPIClientButton;
@property (weak) IBOutlet UIButton* registerAPIClientButton;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleIDLabel;

@property (strong) NSString *userToken;
@property (strong) NSString *emailAddress;

@property (strong) NSPredicate *emailTest;

@end


@implementation RegisterViewController

#pragma mark Lifecycle methods

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    //Build + Version Label
    self.bundleIDLabel.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]];
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build: %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    //Set up email Regex
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    self.emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Integration-Task-3:   Do we have a User Token already?
    //                      Your Backend should provide you with a token or the information that it is missing
    //                      For demo purposes we simply use NSUserDefaults
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserTokenPKey] isKindOfClass:[NSString class]]) {
        //User token available, user should be able to edit/add/delete Payment Instruments associated with it
        self.resetAPIClientButton.enabled = TRUE;
        self.registerAPIClientButton.enabled = TRUE;
        self.resetAPIClientButton.alpha = 1.0;
        self.registerAPIClientButton.alpha = 1.0;
            
        self.userToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserTokenPKey];
        self.emailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsMailAddressKey];
            
        self.userTokenTextField.text = self.userToken;
        self.emailTextField.text = self.emailAddress;
            
        [self.registerAPIClientButton setTitle:@"Edit PIs"  forState:UIControlStateNormal];
            
    } else {
        //No User Token available, ask user to create one
        self.userTokenTextField.text = @"";
        self.emailTextField.text = @"";
            
        self.userToken = Nil;
        self.emailAddress = Nil;
            
        self.resetAPIClientButton.enabled = FALSE;
        self.registerAPIClientButton.enabled = FALSE;
        self.resetAPIClientButton.alpha = .50;
        self.registerAPIClientButton.alpha = .50;
        
        [self.registerAPIClientButton setTitle:@"Register User"  forState:UIControlStateNormal];
    }
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Integration-Task-2: Insert API Key to setup communication between Payleven SDK and Payleven Backend
    [[PLVInAppClient sharedInstance] registerWithAPIKey:@"2c66f5fd510740ec83606bfe65bbdd26"];
    
    if ([[segue identifier] isEqualToString:@"showDetails"]){
        //We have a User Token already user should be able to add/delete/edit Payment Instruments associated to it
        UserTokenDetailViewController * detailVC = (UserTokenDetailViewController*)[segue destinationViewController] ;
        
        detailVC.userToken = self.userToken;
        detailVC.emailAddress = self.emailAddress;
        
    }else if ([[segue identifier] isEqualToString:@"RegisterUserTokenSegue"]){
        //We do not have a User Token, user must create a Payment Instrument to create User Token
        AddPIViewController* addPiForUserTokenVC =  (AddPIViewController*) [segue destinationViewController];
        
        addPiForUserTokenVC.emailAddress = self.emailTextField.text;
        addPiForUserTokenVC.paymentInstrumentIsMandatory = true;
    }
}

#pragma mark UI Interaction Methods
//Reset is implemented for development purposes only, in live environment each user will always have one user token only
- (IBAction)resetPressed:(id)sender {

    self.userTokenTextField.text = @"";
    self.emailTextField.text = @"";
    
    self.resetAPIClientButton.enabled = FALSE;
    self.registerAPIClientButton.enabled = FALSE;
    self.resetAPIClientButton.alpha = .50;
    self.registerAPIClientButton.alpha = .50;
    
    self.userToken = nil;
    self.emailAddress = nil;
    
    [self.registerAPIClientButton setTitle:@"Register User"  forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsUserTokenPKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsMailAddressKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsAllUseCasesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsCurrentUseCaseKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) editOrRegisterUserTokenPressed:(id)sender {
    
    if (self.userToken != Nil) {
        //We have a User Token already user should be able to add/delete/edit Payment Instruments associated to it
        [self performSegueWithIdentifier:@"showDetails" sender:self];
        
    } else {
        //We do not have a User Token, user must create a Payment Instrument to create User Token
        [self performSegueWithIdentifier:@"RegisterUserTokenSegue" sender:self];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userTokenTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

#pragma mark TextField Delegate Methods

//Validate entered email address
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    BOOL validEmail = [self.emailTest evaluateWithObject:replacedString];
    
    if (validEmail) {
        self.resetAPIClientButton.enabled = TRUE;
        self.registerAPIClientButton.enabled = TRUE;
        self.resetAPIClientButton.alpha = 1.0;
        self.registerAPIClientButton.alpha = 1.0;
    } else {
        self.resetAPIClientButton.enabled = FALSE;
        self.registerAPIClientButton.enabled = FALSE;
        self.resetAPIClientButton.alpha = .50;
        self.registerAPIClientButton.alpha = .50;
    }
    
    return TRUE;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

@end
