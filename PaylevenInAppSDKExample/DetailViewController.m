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


#define selectPItoAddActionSheet 666

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface DetailViewController ()


@property (weak) IBOutlet UIButton* getUserTokenButton;

@property (weak) IBOutlet UIButton* listPIButton;
@property (weak) IBOutlet UIButton* addPIButton;
@property (weak) IBOutlet UIButton* backButton;
@property (weak) IBOutlet UIView* activityPlane;
@property (weak) IBOutlet UIView* subPlane;
@property (weak) IBOutlet UIButton* useCaseButton;
@property (weak) IBOutlet UITextField* userTokenTextField;
@property (weak) IBOutlet UITextField* emailTextField;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userTokenTextField.text = self.userToken;
    self.emailTextField.text = self.emailAddress;
    
    self.subPlane.hidden = FALSE;
}

- (void) viewDidAppear:(BOOL)animated  {
    
    [super viewDidAppear:animated];
    
    [self loadUseCases];
    
    [self.useCaseButton setTitle:self.useCase forState:UIControlStateNormal];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    
    [self.useCaseButton setTitle:self.useCase forState:UIControlStateNormal];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unregisterAPI:(id)sender {
    
    self.rootVC.doNotWind = TRUE;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)showEditUseCaseVC:(id)sender {
    
    EditUseCaseViewController* useCaseVC = [[EditUseCaseViewController alloc] initWithNibName:@"EditUseCaseViewController" bundle:Nil];
    
    [self.navigationController pushViewController:useCaseVC animated:YES];

}


-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)listPIs:(id)sender {
    
    self.activityPlane.hidden = FALSE;
    
    [[PLVInAppClient sharedInstance] getPaymentInstrumentsList:self.userTokenTextField.text withUseCase:self.useCase andCompletion:^(NSDictionary* result, NSError* error){
        
        self.activityPlane.hidden = TRUE;
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {

                if ([result objectForKey:@"paymentInstruments"]) {
                    
                    NSArray* piListArray = [result objectForKey:@"paymentInstruments"];
                    
                    PayInstTableViewController* listVC = [[PayInstTableViewController alloc] initWithNibName:@"PayInstTableViewController" bundle:Nil];
                    
                    NSString* listUseCase = self.useCase;
                    
                    if ([result objectForKey:@"useCase"]) { // update the useCase
                        listUseCase = [result objectForKey:@"useCase"];
                    }
                    
                    [listVC setPIArray:piListArray forUserToken:self.userTokenTextField.text andUseCase:listUseCase];
                    
                    [self.navigationController pushViewController:listVC animated:YES];
                    
                    
                } else {
                    [self displayAlertViewWithMessage:@"No PaymentInstruments found"];
                }
            } else {
                
                [self displayAlertViewWithMessage:error.localizedDescription];
            }
        }
    }];
}

- (IBAction)addPIActionSheet:(id)sender {
    
    AddPIViewController* addPiVC = [[AddPIViewController alloc] initWithNibName:@"AddPIViewController" bundle:Nil];
    
    addPiVC.piTypeToCreate = @"CC";
    addPiVC.useCase = self.useCase;
    addPiVC.userToken = self.userTokenTextField.text;
    
    [self.navigationController pushViewController:addPiVC animated:YES];
}

- (void) displayAlertViewWithMessage:(NSString*)message {

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alertView show];
}




@end
