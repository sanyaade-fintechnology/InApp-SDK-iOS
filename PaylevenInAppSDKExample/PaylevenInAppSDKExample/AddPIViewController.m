//
//  AddPIViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 10.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "AddPIViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


#define selectUseCaseActionSheet 456
#define selectPItoAddActionSheet 666

#define textFieldTagOffSet 1000
#define textFieldHeight 40.
#define textFieldPad 10.
#define textFieldMargin 10.

#define TypeDefault 0
#define TypeNumberPad 4


@interface AddPIViewController ()

@property (weak) IBOutlet UIButton* piTypeButton;
@property (weak) IBOutlet UIButton* sendButton;
@property (weak) IBOutlet UIScrollView* scrollView;
@property (weak) IBOutlet UILabel* useCaseLabel;
@property (strong)  NSMutableDictionary* addInfoDict;
@property (strong)  NSArray* keyArray;
@property (strong)  NSArray* keyValueLengthArray;
@property (strong)  NSArray* keyboardTypeArray;
@property (weak)  UITextField* currentTextField;

@end

@implementation AddPIViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _piTypeToCreate = PLVPITypeCC;
        _useCase = @"DEFAULT";
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
    
    self.useCaseLabel.text = [NSString stringWithFormat:@"add PI to useCase: %@",self.useCase];

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
    
    PLVPaymentInstrument* pi = [self fillPIWithType:self.piTypeToCreate andContent:self.addInfoDict];
    
    [self closeKeyboard];
    
    self.currentTextField = Nil;
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:pi forUserToken:self.userToken withUseCase:self.useCase andCompletion:^(NSDictionary* result, NSError* error) {
        
        if (self.currentTextField == Nil) {
            // does not start an other textInput
            // so we clear the fields
            
            for(UITextField* tField in self.scrollView.subviews) {
                
                if ([tField isKindOfClass:[UITextField class]]) {
                    tField.text = @"";
                }
            }
        }
        
    }];
    
    [self backButton:self];
    
}




- (void) createContentKeyArray {
    
    NSString* piType;
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeCC]) {
        
        self.keyArray = @[@"pan",@"expiryMonth",@"expiryYear",@"cvv"];
        self.keyValueLengthArray = @[@21,@2,@2,@4];
        self.keyboardTypeArray = @[@TypeNumberPad,@TypeNumberPad,@TypeNumberPad,@TypeNumberPad];
        
        piType = @"CreditCard";
        
    } else if ([self.piTypeToCreate isEqualToString:PLVPITypeDD]) {
        
        self.keyArray = @[@"accountNumber",@"routingNumber"];
        self.keyValueLengthArray = @[@11,@10];
        self.keyboardTypeArray = @[@TypeDefault,@TypeDefault];
        
        piType = @"Debit Account";
    } else if ([self.piTypeToCreate isEqualToString:PLVPITypeSEPA]) {
        
        self.keyArray = @[@"iban",@"bic"];
        self.keyValueLengthArray = @[@34,@34];
        self.keyboardTypeArray = @[@TypeDefault,@TypeDefault];
        
        piType = @"SEPA Account";
    } else if ([self.piTypeToCreate isEqualToString:PLVPITypePAYPAL]) {
        
        self.keyArray = @[@"authToken"];
        self.keyValueLengthArray = @[@21];
        self.keyboardTypeArray = @[@TypeDefault];
        
        piType = @"Paypay Account";
    }
    
    [self.piTypeButton setTitle:piType forState:UIControlStateNormal];
    
}

- (PLVPaymentInstrument*) fillPIWithType:(NSString*)pitype andContent:(NSDictionary*)content {
    
    PLVPaymentInstrument* pi;
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeCC]) {
        pi = [[PLVPayInstrumentCC alloc] init];
    }
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypePAYPAL]) {
        pi = [[PLVPayInstrumentPAYPAL alloc] init];
    }
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeSEPA]) {
        pi = [[PLVPayInstrumentSEPA alloc] init];
    }
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeDD]) {
        pi = [[PLVPayInstrumentDD alloc] init];
    }
    
    for (NSString* key in content.allKeys) {
        [pi setValue:[content objectForKey:key] forKey:key];
    }
    
    NSError* validateResult = [pi validate];
    
    if (validateResult != Nil) {
        NSLog(@"error: %@",validateResult.localizedFailureReason);
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
        
        newTextField.enablesReturnKeyAutomatically = TRUE;
        
        newTextField.delegate = (id<UITextFieldDelegate>)self;
        
        [scrollView addSubview:newTextFieldFrame];
        
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
    
    if ([string isEqualToString:@""]) {
        // backString
        return TRUE;
    }
    
    NSString* replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSUInteger tfTag = textField.tag - textFieldTagOffSet;
    
    NSNumber* maxLength = [self.keyValueLengthArray objectAtIndex:tfTag];
    
    if (replacedString.length > maxLength.intValue) {
        return FALSE;
    }
    
    NSString* key = [self.keyArray objectAtIndex:tfTag];
    
    [self.addInfoDict setObject:textField.text forKey:key];
    
    if (self.addInfoDict.count == self.keyArray.count) {
        self.sendButton.enabled = TRUE;
        self.sendButton.alpha = 1.0;
    } else {
        self.sendButton.enabled = FALSE;
        self.sendButton.alpha = 0.5;
    }
    
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
        
    }
    
}

@end
