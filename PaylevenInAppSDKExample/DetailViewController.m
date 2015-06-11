//
//  DetailViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 06.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "PayInstTableViewController.h"
#import "AddPIViewController.h"
#import "EditUseCaseViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>
#import "MBProgressHUD.h"

@interface DetailViewController ()

@property (weak) IBOutlet UITextField* userTokenTextField;
@property (weak) IBOutlet UITextField* emailTextField;

@property (weak) IBOutlet UIButton* backButton;

@property (weak) IBOutlet UIButton* useCaseButton;
@property (weak) IBOutlet UIButton* addPIButton;
@property (weak) IBOutlet UIButton* listPIButton;

@end

@implementation DetailViewController

#pragma mark Lifecycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.userTokenTextField.text = self.userToken;
    self.emailTextField.text = self.emailAddress;
}

- (void) viewDidAppear:(BOOL)animated  {
    
    [super viewDidAppear:animated];
    
    [self loadUseCases];
    NSString * selectedUseCase = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedUseCase"];
    
    if (selectedUseCase) {
        self.useCase = selectedUseCase;
    }else{
        self.useCase = @"DEFAULT";
    }
    [self.useCaseButton setTitle:self.useCase forState:UIControlStateNormal];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueIdentifier = segue.identifier;
    
    if ([segueIdentifier isEqualToString:@"AddPISegue"]) {
        
        AddPIViewController* addPiVC = [segue destinationViewController];
        addPiVC.piTypeToCreate = @"CC";
        addPiVC.useCase = self.useCaseButton.titleLabel.text;
        addPiVC.userToken = self.userTokenTextField.text;
        
    }else if ([segueIdentifier isEqualToString:@"ListPIsSegue"]){
        
        PayInstTableViewController* listVC = [segue destinationViewController];
        listVC.userToken = self.userTokenTextField.text;
        listVC.useCase = self.useCase;
        
    }
}

#pragma mark IBAction Methods

- (IBAction)backToRegisterPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark UITextField Delegate methods

-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    
    [self.useCaseButton setTitle:self.useCase forState:UIControlStateNormal];
    
}


@end
