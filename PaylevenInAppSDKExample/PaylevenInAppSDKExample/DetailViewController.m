//
//  DetailViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 06.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "DetailViewController.h"
#import "PayInstTableViewController.h"
#import "AddPIViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>

#define selectEmailAddressActionSheet 333
#define selectPItoAddActionSheet 666
#define selectUseCaseActionSheet 999

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface DetailViewController ()


@property (weak) IBOutlet UITextField* emailTextField;
@property (weak) IBOutlet UIButton* getUserTokenButton;


@property (weak) IBOutlet UIButton* listPIButton;
@property (weak) IBOutlet UIButton* addPIButton;
@property (weak) IBOutlet UIButton* backButton;
@property (weak) IBOutlet UILabel* userTokenLabel;
@property (weak) IBOutlet UIView* activityPlane;
@property (weak) IBOutlet UIView* subPlane;
@property (weak) IBOutlet UIButton* useCaseButton;

@property (strong) NSString* useCase;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.useCase = @"DEFAULT";
    
    [self updateFrameDesign:self.getUserTokenButton];
    [self updateFrameDesign:self.backButton];
    [self updateFrameDesign:self.addPIButton];
    [self updateFrameDesign:self.listPIButton];
    [self updateFrameDesign:self.useCaseButton];
    
    self.useCaseButton.titleLabel.text = self.useCase;
    
}

- (void) updateFrameDesign:(UIView*)button {
    
    button.layer.cornerRadius = 5.f;
    button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    button.layer.borderWidth = 1.f;
    
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
    
    actionSheet.tag = selectEmailAddressActionSheet;
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
 
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == selectEmailAddressActionSheet) {
        
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
    } else if (actionSheet.tag == selectUseCaseActionSheet) {
        
        switch (buttonIndex) {
            case 0:
                self.useCase = @"DEFAULT";
                break;
            case 1:
                self.useCase = @"PRIVATE";
                break;
            case 2:
                self.useCase = @"BUSINESS";
                break;
            default:
                break;
        }
        
        [self.useCaseButton setTitle:self.useCase forState:UIControlStateNormal];
    }
}

- (IBAction)editEmailField:(id)sender {
    
    [self.emailTextField becomeFirstResponder];
    
    self.subPlane.hidden = TRUE;
    self.userTokenLabel.text = @"";

}

-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    return YES;
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
            
            [self displayAlertViewWithMessage:errorMessage];
            
            self.subPlane.hidden = TRUE;
            
            self.userTokenLabel.text = @"";
            
        } else {
            
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                    
                    if ([result objectForKey:@"userToken"]) {
                        
                        self.subPlane.hidden = FALSE;
                        
                        self.userTokenLabel.text = [result objectForKey:@"userToken"];
                        
                    }
                }
            }
            
        }
        
        
    }];
}

- (IBAction)listPIs:(id)sender {
    
    self.activityPlane.hidden = FALSE;
    
    [[PLVInAppClient sharedInstance] listPaymentInstrumentsForUserToken:self.userTokenLabel.text  withUseType:self.useCase andCompletion:^(NSDictionary* result, NSError* error){
        
        self.activityPlane.hidden = TRUE;
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                
                if ([result objectForKey:@"paymentInstruments"]) {
                    
                    NSArray* piListArray = [result objectForKey:@"paymentInstruments"];
                    
                    PayInstTableViewController* listVC = [[PayInstTableViewController alloc] initWithNibName:@"PayInstTableViewController" bundle:Nil];
                    
                    [listVC setPIArray:piListArray forUserToken:self.userTokenLabel.text andUseCase:self.useCase];
                    
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
    addPiVC.userToken = self.userTokenLabel.text;
    
    [self.navigationController pushViewController:addPiVC animated:YES];
        
}


- (void) displayAlertViewWithMessage:(NSString*)message {

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Damm" otherButtonTitles:nil];
    
    [alertView show];
    
}


- (IBAction)showUseCaseActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose UseCase"
                                                             delegate:self
                                                    cancelButtonTitle:(isIPAD ? Nil : @"Cancel")
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"DEFAULT", @"PRIVATE", @"BUSINESS", nil];
    
    actionSheet.tag = selectUseCaseActionSheet;
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    
}


@end
