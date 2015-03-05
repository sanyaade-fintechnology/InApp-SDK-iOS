//
//  AddUserTokenViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 05.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "AddUserTokenViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define selectPItoAddActionSheet 666

#define textFieldTagOffSet 1000
#define buttonTagOffSet 2000
#define textFieldHeight 40.
#define textFieldPad 10.
#define textFieldMargin 10.

#define TypeDefault 0
#define TypeNumberPad 4


#define kUserDefaultsUserTokenPKey @"userToken"
#define kUserDefaultsMailAddressKey @"mailAddress"
#define kUserDefaultsCurrentUseCaseKey @"currentUseCase"
#define kUserDefaultsAllUseCasesKey @"allUseCase"


@interface AddUserTokenViewController ()

@property (weak) IBOutlet UIButton* piTypeButton;
@property (weak) IBOutlet UIButton* sendButton;
@property (weak) IBOutlet UIScrollView* scrollView;
@property (weak) IBOutlet UIButton* useCaseButton;
@property (strong)  NSMutableDictionary* addInfoDict;
@property (strong)  NSMutableDictionary* validationErrors;
@property (strong)  NSArray* keyArray;
@property (strong)  NSArray* keyValueLengthArray;
@property (strong)  NSArray* keyboardTypeArray;
@property (weak)  UITextField* currentTextField;
@property (weak)  UITextField* expiryMonthTextField;
@property (weak)  UITextField* expiryYearTextField;

@end

@implementation AddUserTokenViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _piTypeToCreate = PLVPITypeCC;
        self.useCase = @"DEFAULT";
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    [self updateButtonDesign:self.piTypeButton];
    
    [self updateButtonDesign:self.sendButton];
    
    [self createContentKeyArray];
    
    self.addInfoDict = [NSMutableDictionary new];
    
    self.validationErrors = [NSMutableDictionary new];
    
    [self.useCaseButton setTitle:[NSString stringWithFormat:@"add PI to useCase: %@",self.useCase] forState:UIControlStateNormal];

}


- (void) viewDidAppear:(BOOL)animated {
    
    if (self.keyArray != Nil) {
        [self createTextFieldsOnScrollView:self.scrollView];
    }
}

- (IBAction)backButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) updateButtonDesign:(UIButton*)button {
    
    button.layer.cornerRadius = 5.f;
    button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    button.layer.borderWidth = 1.f;
    
    [self.piTypeButton setTitle:self.useCase forState:UIControlStateNormal];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == selectUseCaseActionSheet) {
        
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        
        [self.useCaseButton setTitle:[NSString stringWithFormat:@"add PI to useCase: %@",self.useCase] forState:UIControlStateNormal];
        
        return;
    }
    

    NSString* currentType = self.piTypeToCreate;
    
    switch (buttonIndex) {
        case 0:
            self.piTypeToCreate  = PLVPITypeCC;
            break;
        case 1:
            self.piTypeToCreate = PLVPITypeDD;
            break;
        case 2:
            self.piTypeToCreate = PLVPITypeSEPA;
            break;
        case 3:
            self.piTypeToCreate = PLVPITypePAYPAL;
            break;
        default:
            break;
    }
    
    if (![currentType isEqualToString:self.piTypeToCreate]) {
        
        [self createContentKeyArray];
        
        [self createTextFieldsOnScrollView:self.scrollView];
        
        self.addInfoDict = [NSMutableDictionary new];
        
    }
    
}

- (IBAction)setCreatePIType:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select type:"
                                                             delegate:self
                                                    cancelButtonTitle:(isIPAD ? Nil : @"Cancel")
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"CreditCard", @"DebitCard", @"SEPA", @"PayPal", nil];
    
    actionSheet.tag = selectPItoAddActionSheet;
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    
}


- (IBAction)sendPI:(id)sender {
    
    PLVPaymentInstrument* newPi = [self fillPIWithType:self.piTypeToCreate andContent:self.addInfoDict];
    
    NSError* validationError;
    
    if (![newPi validatePaymentInstrumentWithError:&validationError]) {
        
        // validation Errors
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:validationError.localizedDescription delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    [self closeKeyboard];
    
    self.currentTextField = Nil;
    
    [[PLVInAppClient sharedInstance] createUserToken:self.emailAddress withPaymentInstrument:newPi useCase:self.useCase andCompletion:^(NSDictionary* result, NSError* error) {
        
        if (error != Nil) {
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alertView show];
            
        } else {
        
            if ([result objectForKey:@"userToken"]) {
                
                [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"userToken"] forKey:kUserDefaultsUserTokenPKey];
                [[NSUserDefaults standardUserDefaults] setObject:self.emailAddress forKey:kUserDefaultsMailAddressKey];
                [[NSUserDefaults standardUserDefaults] setObject:self.useCase forKey:kUserDefaultsCurrentUseCaseKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.navigationController popViewControllerAnimated:true];
            }
            
        }
    }];
    
}




- (void) createContentKeyArray {
    
    NSString* piType;
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeCC]) {
        
        self.keyArray = @[@"cardHolder",@"pan",@"expiryMonth",@"expiryYear",@"cvv"];
        self.keyValueLengthArray = @[@26,@21,@2,@4,@4];
        self.keyboardTypeArray = @[@TypeDefault,@TypeNumberPad,@TypeNumberPad,@TypeNumberPad,@TypeNumberPad];
        
        piType = @"CreditCard";
        
    } else if ([self.piTypeToCreate isEqualToString:PLVPITypeDD]) {
        
        self.keyArray = @[@"accountNo",@"routingNo"];
        self.keyValueLengthArray = @[@11,@10];
        self.keyboardTypeArray = @[@TypeDefault,@TypeDefault];
        
        piType = @"Debit Account";
    } else if ([self.piTypeToCreate isEqualToString:PLVPITypeSEPA]) {
        
        self.keyArray = @[@"iban",@"bic"];
        self.keyValueLengthArray = @[@44,@11];
        self.keyboardTypeArray = @[@TypeDefault,@TypeDefault];
        
        piType = @"SEPA Account";
    } else if ([self.piTypeToCreate isEqualToString:PLVPITypePAYPAL]) {
        
        self.keyArray = @[@"authToken"];
        self.keyValueLengthArray = @[@21];
        self.keyboardTypeArray = @[@TypeDefault];
        
        piType = @"PayPal Account";
    }
    
    [self.piTypeButton setTitle:piType forState:UIControlStateNormal];
    
}

- (PLVPaymentInstrument*) fillPIWithType:(NSString*)pitype andContent:(NSDictionary*)content {
    
    PLVPaymentInstrument* pi;
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeCC]) {
        pi = [PLVPaymentInstrument createCreditCardPaymentInstrumentWithPan:[content objectForKey:@"pan"] expiryMonth:[[content objectForKey:@"expiryMonth"] integerValue] expiryYear:[[content objectForKey:@"expiryYear"] integerValue] cvv:[content objectForKey:@"cvv"] andCardHolder:[content objectForKey:@"cardHolder"]];
    }
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypePAYPAL]) {
        pi = [PLVPaymentInstrument createPAYPALPaymentInstrumentWithToken:[content objectForKey:@"authToken"]];
    }
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeSEPA]) {
        pi = [PLVPaymentInstrument createSEPAPaymentInstrumentWithIBAN:[content objectForKey:@"iban"] andBIC:[content objectForKey:@"bic"]];
    }
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeDD]) {
        pi = [PLVPaymentInstrument createDebitCardPaymentInstrumentWithAccountNo:[content objectForKey:@"accountNo"] andRoutingNo:[content objectForKey:@"routingNo"]];
    }
    
    for (NSString* key in content.allKeys) {
        [pi setValue:[content objectForKey:key] forKey:key];
    }
    
    return pi;
    
}


- (void) createTextFieldsOnScrollView:(UIScrollView*)scrollView {
    
    NSArray* subViews = scrollView.subviews;
    
    for (UIView* subView in subViews) {
        [subView removeFromSuperview];
    }
    
    NSUInteger textFieldIndex = 0;
    
    for (NSString* key in self.keyArray) {
        
        UIView* newTextFieldFrame = [[UIView alloc] initWithFrame:CGRectMake(textFieldMargin,textFieldIndex * (textFieldPad + textFieldHeight), self.view.frame.size.width - (2 * textFieldMargin), textFieldHeight)];
        
        newTextFieldFrame.layer.cornerRadius = 5.f;
        newTextFieldFrame.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        newTextFieldFrame.layer.borderWidth = 1.f;
        
        UITextField* newTextField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldMargin * 2 ,textFieldIndex * (textFieldPad + textFieldHeight), self.view.frame.size.width - (4 * textFieldMargin), textFieldHeight)];
        
        newTextField.tag = textFieldIndex + textFieldTagOffSet;
        
        newTextField.placeholder = key;
        
        NSNumber* keyboardType = [self.keyboardTypeArray objectAtIndex:textFieldIndex];
        
        newTextField.keyboardType = keyboardType.intValue;
        
        newTextField.textColor = [UIColor darkGrayColor];
        
        newTextField.enablesReturnKeyAutomatically = TRUE;
        
        newTextField.delegate = (id<UITextFieldDelegate>)self;
        
        [scrollView addSubview:newTextFieldFrame];
        
        UIButton* validationButton = [[UIButton alloc] initWithFrame:CGRectMake(newTextField.frame.origin.x + newTextField.frame.size.width, newTextField.frame.origin.y, textFieldMargin * 2, newTextField.frame.size.height)];
        
        [validationButton setTitle:@"" forState:UIControlStateNormal];
        
        validationButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.];
        
        [validationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        validationButton.tag = textFieldIndex + buttonTagOffSet;
        
        [validationButton addTarget:self action:@selector(checkValidation:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:validationButton];
        
        [scrollView addSubview:newTextField];
        
        textFieldIndex++;
    }
    
    UIButton* newTextFieldButton = [[UIButton alloc] initWithFrame:CGRectMake(textFieldMargin,textFieldIndex * (textFieldPad + textFieldHeight), self.view.frame.size.width - (2 * textFieldMargin), textFieldHeight * 5)];
    
    [newTextFieldButton addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchDown];
    
    [scrollView addSubview:newTextFieldButton];
    
    
    [scrollView setNeedsDisplay];
    
    if (textFieldIndex > 2) {
        self.scrollView.scrollEnabled = TRUE;
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (textFieldIndex * (textFieldPad + textFieldHeight)) + textFieldHeight * 5)];
    }
    
    [self.scrollView setContentOffset:CGPointMake(0., 0.) animated:TRUE];
    
    self.sendButton.enabled = FALSE;
    self.sendButton.alpha = 0.5;
}

- (void) checkValidation:(id)sender {
    
    
    
    NSLog(@"get Validation Result");
    
}


- (void)closeKeyboard {
    
    [self.currentTextField resignFirstResponder];
    
    self.currentTextField = Nil;
    
    [self.scrollView setContentOffset:CGPointMake(0., 0.) animated:TRUE];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    // scroll View
    
    NSUInteger tfTag = textField.tag - textFieldTagOffSet;
    
    [self.scrollView setContentOffset:CGPointMake(0., (tfTag * (textFieldPad + textFieldHeight)) - 25.) animated:TRUE];
    
    self.currentTextField = textField;
    
    return TRUE;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSUInteger tfTag = textField.tag - textFieldTagOffSet;
    
    NSNumber* maxLength = [self.keyValueLengthArray objectAtIndex:tfTag];
    
    if (replacedString.length > maxLength.intValue) {
        return FALSE;
    }
    
    
    NSString* key = [self.keyArray objectAtIndex:tfTag];
    
    // validate Input
    
    [self validateTextField:textField comingText:replacedString forKey:key];
    
    [self.addInfoDict setObject:replacedString forKey:key];
    
    if (self.addInfoDict.count == self.keyArray.count) {
        self.sendButton.enabled = TRUE;
        self.sendButton.alpha = 1.0;
    } else {
        self.sendButton.enabled = FALSE;
        self.sendButton.alpha = 0.5;
    }
    
    if (([self.addInfoDict objectForKey:@"iban"] != Nil ) && (self.addInfoDict.count == 1) && [self.piTypeToCreate isEqualToString:PLVPITypeSEPA]) {
        // bic is optinal
        self.sendButton.enabled = TRUE;
        self.sendButton.alpha = 1.0;
    }
    
    NSLog(@"Dict: %@",self.addInfoDict);
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return TRUE;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    NSUInteger tfTag = textField.tag - textFieldTagOffSet;
    
    if (tfTag < self.keyArray.count) {
        
        NSString* key = [self.keyArray objectAtIndex:tfTag];
        
        [self.addInfoDict setObject:textField.text forKey:key];
        
        if (self.addInfoDict.count == self.keyArray.count) {
            self.sendButton.enabled = TRUE;
            self.sendButton.alpha = 1.0;
        } else {
            self.sendButton.enabled = FALSE;
            self.sendButton.alpha = 0.5;
        }
        
        if (([self.addInfoDict objectForKey:@"iban"] != Nil ) && (self.addInfoDict.count == 1) && [self.piTypeToCreate isEqualToString:PLVPITypeSEPA]) {
            // bic is optinal
            self.sendButton.enabled = TRUE;
            self.sendButton.alpha = 1.0;
        }
        
    }
}


- (void) validateTextField:(UITextField*)textField comingText:(NSString*)text forKey:(NSString*)key {
    
    if (text == Nil || text.length == 0) {
        return;
    }
    
    NSError* validationError;
    BOOL validationResult = TRUE;
    BOOL findValidation = FALSE;
    
    if ([key isEqualToString:@"pan"]) {
        validationResult = [PLVCreditCardPaymentInstrument validatePan:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"cardHolder"]) {
        validationResult = [PLVCreditCardPaymentInstrument validateCardHolder:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"cvv"]) {
        validationResult = [PLVCreditCardPaymentInstrument validateCVV:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"iban"]) {
        validationResult = [PLVSEPAPaymentInstrument validateIBAN:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"bic"]) {
        validationResult = [PLVSEPAPaymentInstrument validateBIC:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"accountNo"]) {
        validationResult = [PLVDebitCardPaymentInstrument validateAccountNo:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"routingNo"]) {
        validationResult = [PLVDebitCardPaymentInstrument validateRoutingNo:text withError:&validationError];
        findValidation = TRUE;
    } else if ([key isEqualToString:@"authToken"]) {
        validationResult = [PLVPAYPALPaymentInstrument validateAuthToken:text withError:&validationError];
        findValidation = TRUE;
    }  else if ([key isEqualToString:@"expiryMonth"]) {
        
        self.expiryMonthTextField = textField;
        
        if ([self.addInfoDict objectForKey:@"expiryYear"] != Nil) {
            
            long expMonth = text.integerValue;
            
            validationResult = [PLVCreditCardPaymentInstrument validateExpiryMonth:expMonth andYear:[[self.addInfoDict objectForKey:@"expiryYear"] integerValue] withError:&validationError];

            if (self.expiryYearTextField != Nil) {
                
                [self setTextField:self.expiryYearTextField valid:validationResult];
                
                if (validationError) {
                    
                    [self.validationErrors setObject:validationError forKey:@"expiryYear"];
                    
                } else {
                    
                    [self.validationErrors removeObjectForKey:@"expiryYear"];
                }
                
                findValidation = TRUE;
            }
        }
        
    } else if ([key isEqualToString:@"expiryYear"]) {
        
        self.expiryYearTextField = textField;
        
        if ([self.addInfoDict objectForKey:@"expiryMonth"] != Nil) {
            
            long expYear = text.integerValue;
            
            validationResult = [PLVCreditCardPaymentInstrument validateExpiryMonth:[[self.addInfoDict objectForKey:@"expiryYear"] integerValue] andYear:expYear withError:&validationError];
            
            if (self.expiryMonthTextField != Nil) {
                
                [self setTextField:self.expiryMonthTextField valid:validationResult];
                
                if (validationError) {
                    
                    [self.validationErrors setObject:validationError forKey:@"expiryYear"];
                    
                } else {
                    
                    [self.validationErrors removeObjectForKey:@"expiryYear"];
                }
                
                findValidation = TRUE;
            }
        }
        
    }
    
    
    if (findValidation) {
        
        [self setTextField:textField valid:validationResult];
        
        if (validationError) {
            
            [self.validationErrors setObject:validationError forKey:key];
            
        }
    }
    
}

- (void) setTextField:(UITextField*)textField valid:(BOOL)valid {
    
    
    if (valid) {
        
        [textField setTextColor:[UIColor blackColor]];
        
        UIButton* button = (UIButton*)[textField.superview viewWithTag:textField.tag + (buttonTagOffSet - textFieldTagOffSet)];
        
        [button setTitle:@"✔︎" forState:UIControlStateNormal];
        
    } else {
        
        [textField setTextColor:[UIColor darkGrayColor]];
        
        UIButton* button = (UIButton*)[textField.superview viewWithTag:textField.tag + (buttonTagOffSet - textFieldTagOffSet)];
        
        [button setTitle:@"✘" forState:UIControlStateNormal];
    }
    
}


@end
