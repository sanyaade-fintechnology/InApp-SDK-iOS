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
#define textFieldTagOffSet 1000
#define textFieldHeight 40.
#define textFieldPad 10.
#define textFieldMargin 10.

#define TypeNumberPad 4


@interface AddPIViewController ()

@property (weak) IBOutlet UIButton* useCaseButton;
@property (weak) IBOutlet UIButton* sendButton;
@property (weak) IBOutlet UIScrollView* scrollView;
@property (weak) IBOutlet UILabel* piTypeLabel;
@property (strong)  NSString* useCase;
@property (strong)  NSMutableDictionary* addInfoDict;
@property (strong)  NSArray* keyArray;
@property (strong)  NSArray* keyValueLengthArray;
@property (strong)  NSArray* keyboardTypeArray;
@property (weak)  UITextField* currentTextField;

@end

@implementation AddPIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.useCase = @"DEFAULT";
    
    [self updateButtonDesign:self.useCaseButton];
    
    [self updateButtonDesign:self.sendButton];
    
    [self createContentKeyArray];
    
    self.addInfoDict = [NSMutableDictionary new];

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

- (IBAction)showUseCaseActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose UseCsae"
                                                             delegate:self
                                                    cancelButtonTitle:(isIPAD ? Nil : @"Cancel")
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"DEFAULT", @"PRIVATE", @"BUSINESS", nil];
    
    actionSheet.tag = selectUseCaseActionSheet;
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == selectUseCaseActionSheet) {
        
        switch (buttonIndex) {
            case 0:
                self.useCase = @"DEFAULT";
                
                [self updateButtonDesign:self.useCaseButton];
                break;
            case 1:
                self.useCase = @"PRIVATE";
                
                [self updateButtonDesign:self.useCaseButton];
                break;
            case 2:
                self.useCase = @"BUSINESS";
                
                [self updateButtonDesign:self.useCaseButton];
                break;
            default:
                break;
        }
    }
}

- (void) updateButtonDesign:(UIButton*)button {
    
    button.layer.cornerRadius = 10.f;
    button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    button.layer.borderWidth = 1.f;
    
    [self.useCaseButton setTitle:self.useCase forState:UIControlStateNormal];
    
}


- (IBAction)sendPI:(id)sender {
    
   PLVPaymentInstrument* pi = [self fillPIWithType:self.piTypeToCreate andContent:self.addInfoDict];
    
    [[PLVInAppClient sharedInstance] addPaymentInstrument:pi forUserToken:self.userToken withUseCase:self.useCase andCompletion:^(NSDictionary* result, NSError* error) {
        
        
        
    }];
    
}




- (void) createContentKeyArray {
    
    NSString* piType;
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeCC]) {
        
        self.keyArray = @[@"pan",@"expiryMonth",@"expiryYear",@"ccv"];
        self.keyValueLengthArray = @[@21,@2,@2,@4];
        self.keyboardTypeArray = @[@TypeNumberPad,@TypeNumberPad,@TypeNumberPad,@TypeNumberPad];
        
        piType = @"CreditCard";
    }
    
    self.piTypeLabel.text = piType;
}

- (PLVPaymentInstrument*) fillPIWithType:(NSString*)pitype andContent:(NSDictionary*)content {
    
    PLVPaymentInstrument* pi;
    
    if ([self.piTypeToCreate isEqualToString:PLVPITypeCC]) {
        pi = [[PLVPayInstrumentCC alloc] init];
    }
    
    for (NSString* key in content.allKeys) {
        [pi setValue:[content objectForKey:key] forKey:key];
    }
    
    return pi;
    
}

- (void) createTextFieldsOnScrollView:(UIScrollView*)scrollView {
    
    NSUInteger textFieldIndex = 0;
    
    for (NSString* key in self.keyArray) {
        
        UIView* newTextFieldFrame = [[UIView alloc] initWithFrame:CGRectMake(textFieldMargin,textFieldIndex * (textFieldPad + textFieldHeight), self.view.frame.size.width - (2 * textFieldMargin), textFieldHeight)];
        
        newTextFieldFrame.layer.cornerRadius = 5.f;
        newTextFieldFrame.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        newTextFieldFrame.layer.borderWidth = 1.f;
        
        UITextField* newTextField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldMargin,0., self.view.frame.size.width - (2 * textFieldMargin), textFieldHeight)];
        
        newTextField.tag = textFieldIndex + textFieldTagOffSet;
        
        newTextField.placeholder = key;
        
        NSNumber* keyboardType = [self.keyboardTypeArray objectAtIndex:textFieldIndex];
        
        newTextField.keyboardType = keyboardType.intValue;
        
        newTextField.enablesReturnKeyAutomatically = TRUE;
        
        newTextField.delegate = (id<UITextFieldDelegate>)self;
        
        [newTextFieldFrame addSubview:newTextField];
        
        [scrollView addSubview:newTextFieldFrame];
        
        textFieldIndex++;
    }
    
    UIButton* newTextFieldButton = [[UIButton alloc] initWithFrame:CGRectMake(textFieldMargin,textFieldIndex * (textFieldPad + textFieldHeight), self.view.frame.size.width - (2 * textFieldMargin), textFieldHeight * 5)];
    
//    newTextFieldButton.backgroundColor = [UIColor greenColor];
    
    [newTextFieldButton addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchDown];
    
    [scrollView addSubview:newTextFieldButton];
    
    
    if (textFieldIndex > 2) {
        self.scrollView.scrollEnabled = TRUE;
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (textFieldIndex * (textFieldPad + textFieldHeight)) + textFieldHeight * 5)];
    }
    
}

- (void)closeKeyboard {
    
    [self.currentTextField resignFirstResponder];
    
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
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return TRUE;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    NSUInteger tfTag = textField.tag - textFieldTagOffSet;
    
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

@end
