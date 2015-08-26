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

@end

@implementation PayInstrumentsTableCell

@end



@interface PayInstTableViewController ()

@property (weak) IBOutlet UITableView* tableView;
@property (weak) IBOutlet UILabel* useCaseLabel;
@property (strong) NSMutableArray* payInstruments;
@property (strong) NSIndexPath* indexPathToDelete;
@property (strong) NSIndexPath* indexPathFromOrder;
@property (strong) NSIndexPath* indexPathToOrder;


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

    
    //Integration-Task-4: List available Payment Instruments associated with User Token
    [[PLVInAppClient sharedInstance] getPaymentInstrumentsList:self.userToken andCompletion:^(NSArray *paymentInstrumentsArray, NSError *error) {
        
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
    
    PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:indexPath.row];
    
    cell.mainLabel.text = pi.pan;
    cell.typeLabel.text = pi.type;
    cell.validLabel.text = [NSString stringWithFormat:@"%@/%@",pi.expiryMonth,pi.expiryYear];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.indexPathToDelete = [indexPath copy];
        
        //DISABLE Payment Instrument
        PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = [NSString stringWithFormat:@"Disabling %@",pi.pan];
        
        [[PLVInAppClient sharedInstance] disablePaymentInstrument:pi
                                                     forUserToken:self.userToken
                                                    andCompletion:^(NSError *error){
                                                        
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

@end



