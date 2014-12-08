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
#import "AddUserTokenViewController.h"
#import "DetailViewController.h"

#import <PaylevenInAppSDK/PLVInAppSDK.h>


#define kUserDefaultsUserTokenPKey @"userToken"
#define kUserDefaultsMailAddressKey @"mailAddress"
#define kUserDefaultsCurrentUseCaseKey @"currentUseCase"
#define kUserDefaultsAllUseCasesKey @"allUseCase"

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface RootViewController()

@property (weak) IBOutlet UITextField* backEndIPTextField;
@property (weak) IBOutlet UIButton* resetAPIClientButton;
@property (weak) IBOutlet UIButton* registerAPIClientButton;
@property (weak) IBOutlet UIView* setBEipPanel;

@property (weak) IBOutlet UITextField* userTokenTextField;
@property (weak) IBOutlet UITextField* emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *apiKeyLabel;
@property (strong) NSPredicate *emailTest;

@property (strong) NSString *userToken;
@property (strong) NSString *emailAddress;
@property (strong) NSString *useCase;

@property (weak) IBOutlet DetailViewController* detailVC;

@end


@implementation RootViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.doNotWind = FALSE;
    
    self.bundleIDLabel.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build: %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    self.registerAPIClientButton.layer.cornerRadius = 5.f;
    self.registerAPIClientButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.registerAPIClientButton.layer.borderWidth = 1.f;
    
    self.resetAPIClientButton.layer.cornerRadius = 5.f;
    self.resetAPIClientButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.resetAPIClientButton.layer.borderWidth = 1.f;
    
    self.apiKeyLabel.text = @"API Key: 4840bbc6429dacd56bfa98390ddf43";
    
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
    NSLog(@"source VC %p",segue.sourceViewController);
    NSLog(@"destination VC %p",segue.destinationViewController);
    
    if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        self.detailVC = (DetailViewController*)[segue destinationViewController] ;
        
        self.detailVC.userToken = self.userToken;
        self.detailVC.emailAddress = self.emailAddress;
        self.detailVC.useCase = self.useCase;
        self.detailVC.rootVC = self;
    }
}

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

    self.useCase = @"DEFAULT";
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction) startRegisterUserToken:(id)sender {
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:@"4840bbc6429dacd56bfa98390ddf43"];
    
    if (self.userToken != Nil) {
        
        [self performSegueWithIdentifier:@"showDetails" sender:self];
        
    } else {
    
        AddUserTokenViewController* addPiForUserTokenVC = [[AddUserTokenViewController alloc] initWithNibName:@"AddUserTokenViewController" bundle:Nil];
        
        addPiForUserTokenVC.piTypeToCreate = @"CC";
        addPiForUserTokenVC.useCase = @"DEFAULT";
        addPiForUserTokenVC.emailAddress = self.emailTextField.text;
        
        [self.navigationController pushViewController:addPiForUserTokenVC animated:YES];
        
    }
}

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
