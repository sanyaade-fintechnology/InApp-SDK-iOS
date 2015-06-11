//
//  RootViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "RootViewController.h"
#import "AddPIViewController.h"
#import "DetailViewController.h"

#import <PaylevenInAppSDK/PLVInAppSDK.h>


#define kUserDefaultsUserTokenPKey @"userToken"
#define kUserDefaultsMailAddressKey @"mailAddress"
#define kUserDefaultsCurrentUseCaseKey @"currentUseCase"
#define kUserDefaultsAllUseCasesKey @"allUseCase"

@interface RootViewController() <UIActionSheetDelegate>

@property (weak) IBOutlet UITextField* userTokenTextField;
@property (weak) IBOutlet UITextField* emailTextField;

@property (weak) IBOutlet UIButton* resetAPIClientButton;
@property (weak) IBOutlet UIButton* registerAPIClientButton;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleIDLabel;

@property (strong) NSString *userToken;
@property (strong) NSString *emailAddress;
@property (strong) NSString *useCase;

@property (strong) NSPredicate *emailTest;

@end


@implementation RootViewController

#pragma mark Lifecycle methods

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    //Build + Version Label
    self.bundleIDLabel.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]];
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build: %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    //SetUp Email Regex Logic
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    self.emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    [self loadSettings];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self loadSettings];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        DetailViewController * detailVC = (DetailViewController*)[segue destinationViewController] ;
        
        detailVC.userToken = self.userToken;
        detailVC.emailAddress = self.emailAddress;
        detailVC.useCase = self.useCase;
        
    }else if ([[segue identifier] isEqualToString:@"RegisterUserTokenSegue"]){
        
        AddPIViewController* addPiForUserTokenVC =  (AddPIViewController*) [segue destinationViewController];
        
        addPiForUserTokenVC.piTypeToCreate = @"CC";
        addPiForUserTokenVC.useCase = @"DEFAULT";
        addPiForUserTokenVC.emailAddress = self.emailTextField.text;
        
        addPiForUserTokenVC.paymentInstrumentIsMandatory = true;
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userTokenTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

#pragma mark IBAction Methods
- (IBAction)restPress:(id)sender {

    self.userTokenTextField.text = @"";
    self.emailTextField.text = @"";
    
    self.resetAPIClientButton.enabled = FALSE;
    self.registerAPIClientButton.enabled = FALSE;
    self.resetAPIClientButton.alpha = .50;
    self.registerAPIClientButton.alpha = .50;
    
    self.userToken = Nil;
    self.emailAddress = Nil;
    
    [self.registerAPIClientButton setTitle:@"Register User"  forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsUserTokenPKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsMailAddressKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsAllUseCasesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsCurrentUseCaseKey];


    self.useCase = @"DEFAULT";
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction) startRegisterUserToken:(id)sender {
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:@"2c66f5fd510740ec83606bfe65bbdd26"];
    
    if (self.userToken != Nil) {
        [self performSegueWithIdentifier:@"showDetails" sender:self];
        
    } else {
        [self performSegueWithIdentifier:@"RegisterUserTokenSegue" sender:self];
    }
    
}

#pragma mark Private Methods

//Checks for User Token, sets Up UI for Register new User Token or Edit PaymentInstruments of existing
- (void) loadSettings {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserTokenPKey] isKindOfClass:[NSString class]]) {
        
        self.resetAPIClientButton.enabled = TRUE;
        self.registerAPIClientButton.enabled = TRUE;
        self.resetAPIClientButton.alpha = 1.0;
        self.registerAPIClientButton.alpha = 1.0;
        
        self.userToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserTokenPKey];
        self.emailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsMailAddressKey];
        self.useCase = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCurrentUseCaseKey];
        
        self.userTokenTextField.text = self.userToken;
        self.emailTextField.text = self.emailAddress;
        
        [self.registerAPIClientButton setTitle:@"Edit PIs"  forState:UIControlStateNormal];
        
    } else {
        
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

#pragma mark TextField Delegate Methods

//Validate if valid Email was entered
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
