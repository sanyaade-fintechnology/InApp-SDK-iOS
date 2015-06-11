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
    hud.labelText = [NSString stringWithFormat:@"Loading: %@", self.useCase];

    [[PLVInAppClient sharedInstance] getPaymentInstrumentsList:self.userToken withUseCase:self.useCase andCompletion:^(NSDictionary* result, NSError* error){
        
        if (!error) {
            
            NSArray* piListArray = [result objectForKey:@"paymentInstruments"];
            self.payInstruments = [NSMutableArray arrayWithArray:piListArray];
            hud.labelText = [NSString stringWithFormat:@"Found: %ld PIs", self.payInstruments.count];
            
        } else {
            //[self displayAlertViewWithMessage:error.localizedDescription];
            self.payInstruments = [NSMutableArray arrayWithArray:@[]];
            hud.labelText = error.localizedDescription;
        }
        [self.tableView reloadData];
        [hud hide:YES afterDelay:1.0];
        
    }];
    
    self.useCaseLabel.text = [NSString stringWithFormat:@"useCase: %@",self.useCase];
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
        [self deletePaymentInstrument];
    }
}

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
                                                    withUseCase:self.useCase
                                                  andCompletion:^(NSDictionary* result, NSError* error){
        
        if (error) {
            hud.labelText = error.localizedDescription;
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                //New Order confirmed
                self.payInstruments = tempOrder;
                hud.labelText = @"Success";
            }
            
            [self.tableView reloadData];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.payInstruments.count;
}

#pragma mark AlertView Methods

//Ask user if she/he wants to DISABLE (meaning deleting PI from all Use Cases) or REMOVE (meaning remove PI from specific Use Case) Payment Instrument
- (void) deletePaymentInstrument {
    
    NSString* message = [NSString stringWithFormat:@"Disable PI or\nremove from %@ Use Case?", self.useCase];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Disable or Remove" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Disable",[NSString stringWithFormat:@"Remove from %@", self.useCase],nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (buttonIndex == 1) {
        //DISABLE PI
        PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];

        hud.labelText = [NSString stringWithFormat:@"Disabling %@ from %@",pi.pan, self.useCase];
        
        [[PLVInAppClient sharedInstance] disablePaymentInstrument:pi
                                                     forUserToken:self.userToken
                                                    andCompletion:^(NSDictionary* result, NSError* error){
            
            if (error) {
                hud.labelText = error.localizedDescription;
            } else {
                hud.labelText = @"Success";
                
                //Delete PI from Array
                NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.payInstruments];
                [newArray removeObjectAtIndex:self.indexPathToDelete.row];
                self.payInstruments = newArray;
                
                // Animate the deletion
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
            }
                                                        
            [hud hide:YES afterDelay:1.0];
            self.indexPathToDelete = Nil;
        }];
    } else if (buttonIndex == 2) {
    // REMOVE PI from UseCase
        PLVCreditCardPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
        
        hud.labelText = [NSString stringWithFormat:@"Removing %@",pi.pan];
        
        [[PLVInAppClient sharedInstance] removePaymentInstrument:pi
                                                     fromUseCase:self.useCase
                                                    forUserToken:self.userToken
                                                   andCompletion:^(NSDictionary* result, NSError* error){
            
            if (error) {
                hud.labelText = error.localizedDescription;
            } else {
                hud.labelText = @"Success";

                //Delete PI from Array
                NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.payInstruments];
                [newArray removeObjectAtIndex:self.indexPathToDelete.row];
                self.payInstruments = newArray;
                
                // Animate the deletion
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
            }
            [hud hide:YES afterDelay:1.0];
            self.indexPathToDelete = Nil;
        }];
    } else if (buttonIndex == 0){
    // CANCEL Alert
    }
}

@end



