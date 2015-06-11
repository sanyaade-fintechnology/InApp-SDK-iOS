//
//  AddPIViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 10.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "AddPIViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>
#import "MBProgressHUD.h"

#define kUserDefaultsUserTokenPKey @"userToken"
#define kUserDefaultsMailAddressKey @"mailAddress"
#define kUserDefaultsCurrentUseCaseKey @"currentUseCase"
#define kUserDefaultsAllUseCasesKey @"allUseCase"


@interface AddPIViewController () <UITextFieldDelegate>

@property (weak) IBOutlet UIButton* addButton;
@property (weak, nonatomic) IBOutlet UIButton *dontAddButton;

@property (weak, nonatomic) IBOutlet UILabel *useCaseLabel;

@property (weak) IBOutlet  UITextField* panTextField;
@property (weak) IBOutlet  UITextField* cardholderTextField;
@property (weak) IBOutlet  UITextField* expiryYearTextField;
@property (weak) IBOutlet  UITextField* expiryMonthTextField;
@property (weak) IBOutlet  UITextField* cvvTextField;

@end

@implementation AddPIViewController

#pragma mark VC Lifecycle Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.useCaseLabel.text = [NSString stringWithFormat:@"add PI to useCase: %@",self.useCase];
    
    [self.panTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.cardholderTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.expiryMonthTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.expiryYearTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.cvvTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.paymentInstrumentIsMandatory) {
        self.dontAddButton.enabled = false;
        self.dontAddButton.alpha = 0.0;
    }else{
        self.dontAddButton.enabled = true;
        self.dontAddButton.alpha = 1.0;
    }
}

#pragma mark UI Interaction Methods

- (IBAction)sendPI:(id)sender {
    
    [self closeKeyboard];
    
    //Create Payment Instument
    PLVPaymentInstrument* newCreditCardPi = [PLVPaymentInstrument createCreditCardPaymentInstrumentWithPan:self.panTextField.text
                                                                                               expiryMonth:self.expiryMonthTextField.text
                                                                                                expiryYear:self.expiryYearTextField.text
                                                                                                       cvv:self.cvvTextField.text
                                                                                             andCardHolder:self.cardholderTextField.text];
    if (self.userToken) {
        //Already have a User Token, simply add it
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Adding PI";
        
        [[PLVInAppClient sharedInstance] addPaymentInstrument:newCreditCardPi
                                                 forUserToken:self.userToken
                                                  withUseCase:self.useCase
                                                andCompletion:^(NSDictionary* result, NSError* error) {
            
            if (error) {
                hud.labelText = error.localizedDescription;
            } else {
                hud.labelText = @"Success";
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:1.0];
            }
                                                    
           [hud hide:YES afterDelay:1.5];
        }];
        
    }else{
        //Don't have a User Token yet, Create it with PI
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Create Token & \nAdd PI";
        
        [[PLVInAppClient sharedInstance] createUserToken:self.emailAddress
                                   withPaymentInstrument:newCreditCardPi
                                                 useCase:self.useCase
                                           andCompletion:^(NSDictionary* result, NSError* error) {
            
            if (error) {
                hud.labelText = error.localizedDescription;
                [hud hide:YES afterDelay:1.0];
            } else {
                if ([result objectForKey:@"userToken"]) {
                    
                    hud.labelText = @"Success";
                    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:1.0];
                    
                    //Store User Token in NSUserDefaults, in a Production Environment you want to store this in your Backend
                    [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"userToken"] forKey:kUserDefaultsUserTokenPKey];
                    [[NSUserDefaults standardUserDefaults] setObject:self.emailAddress forKey:kUserDefaultsMailAddressKey];
                    [[NSUserDefaults standardUserDefaults] setObject:self.useCase forKey:kUserDefaultsCurrentUseCaseKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                
            }
        }];
        
    }
}

- (IBAction)dismissAddPiButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark Private Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyboard];
}

- (void)closeKeyboard {
    [self.panTextField resignFirstResponder];
    [self.cardholderTextField resignFirstResponder];
    [self.expiryYearTextField resignFirstResponder];
    [self.expiryMonthTextField resignFirstResponder];
    [self.cvvTextField resignFirstResponder];
}

#pragma mark Text Input Validation Methods

//Check Field Values when Values Change
-(void)textFieldDidChange:(UITextField*) sender {
    
    UIColor * okColor = [UIColor greenColor];
    UIColor * errorColor = [UIColor colorWithRed:0xFF/255.0 green:0x42/255.0 blue:0x3E/255.0 alpha:0xFF/255.0];
    
    //Contains all Errors, for UI Purposes
    NSMutableArray * errorArray = [NSMutableArray new];
    
    //Pan Validation
    NSError * panError;
    BOOL validPan = [PLVCreditCardPaymentInstrument validatePan:self.panTextField.text withError:&panError];
    
    if (validPan) {
        self.panTextField.backgroundColor = okColor;
    }else{
        self.panTextField.backgroundColor = errorColor;
        [errorArray addObject:panError];
    }
    
    //Cardholder Validation
    NSError * cardHolderError;
    BOOL validCardHolder = [PLVCreditCardPaymentInstrument validateCardHolder:self.cardholderTextField.text withError:&cardHolderError];
        
    if (validCardHolder) {
        self.cardholderTextField.backgroundColor = okColor;
    }else{
        self.cardholderTextField.backgroundColor = errorColor;
        [errorArray addObject:cardHolderError];
    }
    
    //Expiry Month Validation
    NSError * expMonthError;
    BOOL validExpMonth = [PLVCreditCardPaymentInstrument validateExpiryMonth:self.expiryMonthTextField.text withError:&expMonthError];
        
    if (validExpMonth) {
        self.expiryMonthTextField.backgroundColor = okColor;
    }else{
        self.expiryMonthTextField.backgroundColor = errorColor;
        [errorArray addObject:expMonthError];
    }
    
    //Expiry Year Validation
    NSError * expYearError;
    BOOL validExpYear = [PLVCreditCardPaymentInstrument validateExpiryYear:self.expiryYearTextField.text withError:&expYearError];
        
    if (validExpYear) {
        self.expiryYearTextField.backgroundColor = okColor;
    }else{
        self.expiryYearTextField.backgroundColor = errorColor;
        [errorArray addObject:expYearError];
    }
    
    //CVV Validation
    NSError * cvvError;
    BOOL validCvv = [PLVCreditCardPaymentInstrument validateCVV:self.cvvTextField.text withError:&cvvError];
        
    if (validCvv) {
        self.cvvTextField.backgroundColor = okColor;
    }else{
        self.cvvTextField.backgroundColor = errorColor;
        [errorArray addObject:cvvError];
    }
    
    //Disable/Enable Add Button
    if (errorArray.count == 0) {
        self.addButton.enabled = true;
        self.addButton.alpha = 1.0;
    }else{
        self.addButton.enabled = false;
        self.addButton.alpha = 0.5;
    }
}

@end
