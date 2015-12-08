//
//  PayInstTableViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 07.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PayInstTableViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>
#import "MBProgressHUD.h"

#define piListTableViewCell @"piListTableViewCell"

@interface PayInstrumentsTableCell : UITableViewCell

@property (weak) IBOutlet UILabel* typeLabel;
@property (weak) IBOutlet UILabel* mainLabel;
@property (weak) IBOutlet UILabel* validLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockedLabel;
@property (weak, nonatomic) IBOutlet UISwitch *disableSwitch;
@property (weak, nonatomic) IBOutlet UIView *piContentView;
@property (weak, nonatomic) IBOutlet UITextField *cvvTextField;

@property (weak, nonatomic) IBOutlet UIButton *validateButton;

@end

@implementation PayInstrumentsTableCell

@end



@interface PayInstTableViewController () <UITextFieldDelegate>

@property (weak) IBOutlet UITableView* tableView;
@property (weak) IBOutlet UILabel* useCaseLabel;
@property (strong) NSMutableArray* payInstruments;
@property (strong) NSIndexPath* indexPathToDelete;
@property (strong) NSIndexPath* indexPathFromOrder;
@property (strong) NSIndexPath* indexPathToOrder;
@property (strong) UIView* superview;
@property (weak, nonatomic) IBOutlet UILabel *currentUseCase;

- (IBAction)changeSwitch:(id)sender;

- (IBAction)validatePressed:(id)sender;

@end

@implementation PayInstTableViewController

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Loading"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.currentUseCase.text = self.useCase;
    
    //Integration-Task-4: List available Payment Instruments associated with User Token
    
    
    [[PLVInAppClient sharedInstance] getPaymentInstrumentsList:self.userToken andUseCase:self.useCase andCompletion:^(NSArray *paymentInstrumentsArray, NSError *error) {
        
        if (!error) {
            self.payInstruments = [NSMutableArray arrayWithArray:paymentInstrumentsArray];
            hud.labelText = [NSString stringWithFormat:@"Found: %ld PIs", (unsigned long)self.payInstruments.count];
        } else {
            self.payInstruments = [NSMutableArray arrayWithArray:@[]];
            NSString * errorMessage = [NSString stringWithFormat:@"%@ - %ld", error.localizedDescription, (long)error.code];
            hud.labelText = errorMessage;
        }
        [self.tableView reloadData];
        [hud hide:YES afterDelay:1.0];
        
    }];
    
}

#pragma mark UI Interaction Methods

- (IBAction)backButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (IBAction)enterEditMode:(id)sender {
    
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }
}

#pragma mark Table View Delegate and Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PayInstrumentsTableCell* cell = (PayInstrumentsTableCell*)[tableView dequeueReusableCellWithIdentifier:piListTableViewCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:indexPath.row];
    
    cell.mainLabel.text = pi.pan;
    cell.typeLabel.text = pi.type;
    cell.validLabel.text = [NSString stringWithFormat:@"%@/%@",pi.expiryMonth,pi.expiryYear];
    cell.validateButton.enabled = NO;
    cell.cvvTextField.enabled = NO;
    
    [cell.cvvTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    switch (pi.state) {
        case PLVPaymentInstrumentOK:
            cell.piContentView.backgroundColor = [UIColor clearColor];
            break;
        case PLVPaymentInstrumentInvalid:
            cell.mainLabel.textColor = [UIColor grayColor];
            cell.validLabel.textColor = [UIColor grayColor];
            cell.cvvTextField.enabled = YES;
            break;
        case PLVPaymentInstrumentDisabled:
            [cell.disableSwitch setOn:NO];
            break;
        default:
            break;
    }
    
    if (pi.blocked) {
        cell.blockedLabel.text = @"BLOCKED";
    } else {
        cell.blockedLabel.text = @"";
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.indexPathToDelete = [indexPath copy];
        
        //Remove Payment Instrument
        PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = [NSString stringWithFormat:@"Disabling %@",pi.pan];
        
        [[PLVInAppClient sharedInstance] removePaymentInstrument:pi
                                                     fromUseCase:[self checkUseCase:self.useCase]
                                                    forUserToken:self.userToken
                                                   andCompletion:^(NSError *error) {
            
            if (error) {
                NSString * errorMessage = [NSString stringWithFormat:@"%@ - %ld", error.localizedDescription, (long)error.code];
                hud.labelText = errorMessage;
            } else {
                hud.labelText = @"Success";
                
                //Delete PI from Array
                NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.payInstruments];
                [newArray removeObjectAtIndex:self.indexPathToDelete.row];
                self.payInstruments = newArray;
                
                // Animate deletion
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [hud hide:YES afterDelay:1.0];
            self.indexPathToDelete = Nil;
        }];
    }
}

//Integration-Task-6: Allow user to reorder available Payment Instruments associated with User Token
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    if (fromIndexPath.row == toIndexPath.row) {
        return;
    }
    
    //Reorder
    self.indexPathFromOrder = [fromIndexPath copy];
    self.indexPathToOrder = [toIndexPath copy];
    
    PLVPaymentInstrument *piReOrderItem = [self.payInstruments objectAtIndex:fromIndexPath.row];
    
    NSMutableArray* tempOrder = [NSMutableArray arrayWithArray:self.payInstruments];
    [tempOrder  removeObject:piReOrderItem];
    [tempOrder  insertObject:piReOrderItem atIndex:toIndexPath.row];
    
    NSOrderedSet* ordedSet = [[NSOrderedSet alloc] initWithArray:tempOrder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Reordering...";
    
    [[PLVInAppClient sharedInstance] setPaymentInstrumentsOrder:ordedSet 
                                                   forUserToken:self.userToken
                                                     andUseCase:[self checkUseCase:self.useCase]
                                                  andCompletion:^(NSError *error) {
                                                      
        if (error) {
            NSString * errorMessage = [NSString stringWithFormat:@"%@ - %ld", error.localizedDescription, (long)error.code];
            hud.labelText = errorMessage;
        } else {
            //New Order confirmed
            self.payInstruments = tempOrder;
            hud.labelText = @"Success";
            [self.tableView reloadData];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.payInstruments.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVPaymentInstrument * selectedPi = (PLVPaymentInstrument*) [self.payInstruments objectAtIndex:indexPath.row];
    NSString * selectedPiInfoMessage;
    
    if ([selectedPi.type isEqualToString:PLVPITypeCC]) {
        PLVCreditCardPaymentInstrument * selectedCreditCardPi = (PLVCreditCardPaymentInstrument *) selectedPi;
        selectedPiInfoMessage = [NSString stringWithFormat:@"PAN: %@,\n Brand: %@ ,\n Name: %@,\n expiry: %@/%@",selectedCreditCardPi.pan, selectedCreditCardPi.cardBrand, selectedCreditCardPi.cardHolder,selectedCreditCardPi.expiryMonth,selectedCreditCardPi.expiryYear];
    }
    
    if (selectedPiInfoMessage) {
        UIAlertView * piInfoAlertView = [[UIAlertView alloc] initWithTitle:@"Info" message:selectedPiInfoMessage delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [piInfoAlertView show];
    }
}

- (IBAction)changeSwitch:(id)sender {
    
    UISwitch *switchObject = (UISwitch *)sender;
    
    UITableViewCell* tableCell = [self superCell:switchObject];
    
    self.indexPathToDelete = [self.tableView indexPathForCell:tableCell];
    
    
    //DISABLE Payment Instrument
    PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PayInstTableViewController __weak *selfWeak = self;
    
    if(switchObject.isOn){
        [switchObject setOn:YES animated:YES];
        
        hud.labelText = [NSString stringWithFormat:@"Enabling %@",pi.pan];
        
        [[PLVInAppClient sharedInstance] editPaymentInstrument:pi
                                                  forUserToken:self.userToken
                                                   withUseCase:[self checkUseCase:self.useCase]
                                                    withAction:PLVPaymentInstrumentEnable
                                                       withCVV:@""
                                                 andCompletion:^(PLVPaymentInstrument *paymentInstrument, NSError *error) {
                                                     
                                                     if (error) {
                                                         NSString * errorMessage = [NSString stringWithFormat:@"%@ - %ld", error.localizedDescription, (long)error.code];
                                                         hud.labelText = errorMessage;
                                                     } else {
                                                         hud.labelText = @"Success";
                                                         PLVCreditCardPaymentInstrument *updatedPi = (PLVCreditCardPaymentInstrument*)paymentInstrument;
                                                        
                                                         switch (updatedPi.state) {
                                                             case PLVPaymentInstrumentOK:
                                                                  [switchObject setOn:YES animated:YES];
                                                                 break;
                                                             case PLVPaymentInstrumentDisabled:
                                                                  [switchObject setOn:NO animated:YES];
                                                                 break;
                                                                 
                                                             case PLVPaymentInstrumentInvalid:
                                                                  [switchObject setOn:YES animated:YES];
                                                                 break;
                                                             default:
                                                                 break;
                                                         }
                                                         
                                                         [selfWeak.payInstruments replaceObjectAtIndex:self.indexPathToDelete.row withObject:updatedPi];
                                                     }
                                                     
                                                     [hud hide:YES afterDelay:1.0];
                                                     self.indexPathToDelete = Nil;
                                                     
                                                 }];

    } else {
        [switchObject setOn:NO animated:YES];
        
        hud.labelText = [NSString stringWithFormat:@"Disabling %@",pi.pan];
        
        
        [[PLVInAppClient sharedInstance] editPaymentInstrument:pi
                                                  forUserToken:self.userToken
                                                   withUseCase:[self checkUseCase:self.useCase]
                                                    withAction:PLVPaymentInstrumentDisable
                                                       withCVV:@""
                                                 andCompletion:^(PLVPaymentInstrument *paymentInstrument, NSError *error) {
                                                     
                                                     if (error) {
                                                         NSString * errorMessage = [NSString stringWithFormat:@"%@ - %ld", error.localizedDescription, (long)error.code];
                                                         hud.labelText = errorMessage;
                                                     } else {
                                                         hud.labelText = @"Success";
                                                         PLVCreditCardPaymentInstrument *updatedPi = (PLVCreditCardPaymentInstrument*)paymentInstrument;
                                                         
                                                         switch (updatedPi.state) {
                                                             case PLVPaymentInstrumentOK:
                                                                 [switchObject setOn:YES animated:YES];
                                                                 break;
                                                             case PLVPaymentInstrumentDisabled:
                                                                 [switchObject setOn:NO animated:YES];
                                                                 break;
                                                                 
                                                             case PLVPaymentInstrumentInvalid:
                                                                 [switchObject setOn:YES animated:YES];
                                                                 break;
                                                             default:
                                                                 break;
                                                         }
                                                         
                                                         [selfWeak.payInstruments replaceObjectAtIndex:self.indexPathToDelete.row withObject:updatedPi];

                                                     }
                                                     
                                                     [hud hide:YES afterDelay:1.0];
                                                     self.indexPathToDelete = Nil;
            
        }];
        
    }
}

- (IBAction)validatePressed:(id)sender
{
    PayInstrumentsTableCell* tableCell = (PayInstrumentsTableCell *)[self superCell:sender];
    
    self.indexPathToDelete = [self.tableView indexPathForCell:tableCell];
    
    //Validate Payment Instrument
    PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Validating %@",pi.pan];
    [tableCell.cvvTextField resignFirstResponder];
    
    [[PLVInAppClient sharedInstance] editPaymentInstrument:pi
                                              forUserToken:self.userToken
                                               withUseCase:[self checkUseCase:self.useCase]
                                                withAction:PLVPaymentInstrumentValidate
                                                   withCVV:tableCell.cvvTextField.text
                                             andCompletion:^(PLVPaymentInstrument *paymentInstrument, NSError *error) {
                                                 
                                                 if (error) {
                                                     NSString * errorMessage = [NSString stringWithFormat:@"%@ - %ld", error.localizedDescription, (long)error.code];
                                                     hud.labelText = errorMessage;
                                                     [hud hide:YES afterDelay:1.0];
                                                 } else {
                                                     PLVCreditCardPaymentInstrument *pi = (PLVCreditCardPaymentInstrument*)paymentInstrument;

                                                     switch (pi.state) {
                                                         case PLVPaymentInstrumentOK:
                                                             tableCell.piContentView.backgroundColor = [UIColor clearColor];
                                                             tableCell.mainLabel.textColor = [UIColor blackColor];
                                                             tableCell.validLabel.textColor = [UIColor blackColor];
                                                             tableCell.cvvTextField.enabled = NO;
                                                             tableCell.validateButton.enabled = NO;
                                                             break;
                                                         case PLVPaymentInstrumentInvalid:
                                                             tableCell.mainLabel.textColor = [UIColor grayColor];
                                                             tableCell.validLabel.textColor = [UIColor grayColor];
                                                             tableCell.cvvTextField.enabled = YES;
                                                             tableCell.validateButton.enabled = YES;
                                                             break;
                                                         case PLVPaymentInstrumentDisabled:
                                                             tableCell.piContentView.backgroundColor = [UIColor clearColor];
                                                             tableCell.mainLabel.textColor = [UIColor blackColor];
                                                             tableCell.validLabel.textColor = [UIColor blackColor];
                                                             tableCell.cvvTextField.enabled = NO;
                                                             tableCell.validateButton.enabled = NO;
                                                             [tableCell.disableSwitch setOn:NO];
                                                             break;
                                                         default:
                                                             break;
                                                        }
                                                     
                                                     if (pi.blocked) {
                                                         tableCell.blockedLabel.text = @"BLOCKED";
                                                     } else {
                                                         tableCell.blockedLabel.text = @"";
                                                     }
                                                     
                                                     tableCell.cvvTextField.text = @"";
                                                     
                                                     hud.labelText = @"Validate";
                                                   
                                                 }
                                                 
                                                 [hud hide:YES afterDelay:1.0];
                                                 
                                             }];

}

- (UITableViewCell*)superCell:(UIView*)inputView
{

    if (!inputView) {
        return nil;
    }
    
    
    if ([inputView isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)inputView;
    }
    
    return [self superCell:inputView.superview];
}

#pragma mark Helper

- (NSString*) checkUseCase:(NSString*)useCase {
    
    if ( useCase != Nil && ![useCase isEqualToString:@""]) {
        return useCase;
    }
    
    return @"DEFAULT";
}

- (void) textFieldEditingChanged:(UITextField *)textField {
    if (textField.text.length >= 3) {
        PayInstrumentsTableCell *cell = (PayInstrumentsTableCell*)[self superCell:textField];
        cell.validateButton.enabled = YES;
        cell.validateButton.userInteractionEnabled = YES;
    } else {
        PayInstrumentsTableCell *cell = (PayInstrumentsTableCell*)[self superCell:textField];
        cell.validateButton.enabled = NO;
        cell.validateButton.userInteractionEnabled = NO;
    }
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.tableView];
    CGPoint contentOffset = self.tableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - 80);
    
    NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
    [self.tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
}

@end



