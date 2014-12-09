//
//  PayInstTableViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 07.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PayInstTableViewController.h"
#import <PaylevenInAppSDK/PLVInAppSDK.h>

#define piLiastTableViewCell @"piLiastTableViewCell"

@interface PayInstrumentsTableCell : UITableViewCell

@property (weak) IBOutlet UILabel* typeLabel;
@property (weak) IBOutlet UILabel* mainLabel;
@property (weak) IBOutlet UILabel* validLabel;

@end

@implementation PayInstrumentsTableCell



@end

@interface PayInstTableViewController ()

@property (weak) IBOutlet UITableView* tableView;
@property (weak) IBOutlet UIView* activityPlane;
@property (weak) IBOutlet UIButton* editTableButton;
@property (weak) IBOutlet UILabel* useCaseLabel;
@property (strong) NSMutableArray* payInstruments;
@property (strong) NSString* userToken;
@property (strong) NSString* useCase;
@property (strong) NSIndexPath* indexPathToDelete;
@property (strong) NSIndexPath* indexPathFromOrder;
@property (strong) NSIndexPath* indexPathToOrder;
@property (nonatomic) BOOL automaticReOrder;


@end

@implementation PayInstTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib* cellNib = [UINib nibWithNibName:@"PayInstrumentsTableCell" bundle:Nil];

    [self.tableView registerNib:cellNib forCellReuseIdentifier:piLiastTableViewCell];
    
    [self.tableView reloadData];
    
    self.useCaseLabel.text = [NSString stringWithFormat:@"useCase: %@",self.useCase];
}

- (IBAction)backButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPIArray:(NSArray*)piArray forUserToken:(NSString*)userToken andUseCase:(NSString*)useCase {
    
    self.userToken = userToken;
    self.payInstruments = [NSMutableArray arrayWithArray:piArray];
    self.useCase = useCase;
    self.useCaseLabel.text = self.useCase;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PayInstrumentsTableCell* cell = (PayInstrumentsTableCell*)[tableView dequeueReusableCellWithIdentifier:piLiastTableViewCell forIndexPath:indexPath];
    
    PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:indexPath.row];
    
    cell.mainLabel.text = [self humanIdentifierForPI:pi];
    cell.typeLabel.text = [self humanTypeForShort:pi.type];
    cell.validLabel.text = [self humandValidForPI:pi];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.payInstruments.count;
}

- (NSString*) humanTypeForShort:(NSString*)shortType {
    
    if([shortType isEqualToString:@"CC"]) {
        return @"CreditCard";
    } else if([shortType isEqualToString:@"DD"]) {
        return @"DebitCard";
    } else if([shortType isEqualToString:@"SEPA"]) {
        return @"SEPA Account";
    } else if([shortType isEqualToString:@"PAYPAL"]) {
        return @"PaylPal";
    }  else {
        return @"unknown";
    }
    
}

- (NSString*) humanIdentifierForPI:(PLVPaymentInstrument*)pi {
    
    NSString* shortType = pi.type;
    
    if([shortType isEqualToString:@"CC"]) {
        PLVPayInstrumentCC* cc = (PLVPayInstrumentCC*)pi;
        return cc.pan;
    } else if([shortType isEqualToString:@"DD"]) {
        PLVPayInstrumentDD* cc = (PLVPayInstrumentDD*)pi;
        return [NSString stringWithFormat:@"Account: %@",cc.accountNo];
    } else if([shortType isEqualToString:@"SEPA"]) {
        PLVPayInstrumentSEPA* cc = (PLVPayInstrumentSEPA*)pi;
        return [NSString stringWithFormat:@"IBAN: %@",cc.iban];
    } else if([shortType isEqualToString:@"PAYPAL"]) {
        PLVPayInstrumentPAYPAL* cc = (PLVPayInstrumentPAYPAL*)pi;
        return [NSString stringWithFormat:@"Auth: %@",cc.authToken];
    }  else {
        return @"unknown";
    }
}

- (NSString*) humanDetailsForPI:(PLVPaymentInstrument*)pi {
    
    NSString* shortType = pi.type;
    
    if([shortType isEqualToString:@"CC"]) {
        PLVPayInstrumentCC* cc = (PLVPayInstrumentCC*)pi;
        
        NSArray* details = @[@"  ",[NSString stringWithFormat:@"PAN: %@",cc.pan],[NSString stringWithFormat:@"EXPIRYDATE: %@/%@",cc.expiryMonth,cc.expiryYear],[NSString stringWithFormat:@"BRAND: %@",cc.cardBrand]];
        
        return [details componentsJoinedByString:@"\n"];

    } else if([shortType isEqualToString:@"DD"]) {
        PLVPayInstrumentDD* cc = (PLVPayInstrumentDD*)pi;
        
        NSArray* details = @[@"  ",[NSString stringWithFormat:@"Account: %@",cc.accountNo],[NSString stringWithFormat:@"Routing: %@",cc.routingNo]];
        
        return [details componentsJoinedByString:@"\n"];
    } else if([shortType isEqualToString:@"SEPA"]) {
        PLVPayInstrumentSEPA* cc = (PLVPayInstrumentSEPA*)pi;
        
        NSArray* details = @[@"  ",[NSString stringWithFormat:@"IBAN: %@",cc.iban],[NSString stringWithFormat:@"BIC: %@",cc.bic]];
        
        return [details componentsJoinedByString:@"\n"];
    } else if([shortType isEqualToString:@"PAYPAL"]) {
        
        PLVPayInstrumentPAYPAL* cc = (PLVPayInstrumentPAYPAL*)pi;
        
        NSArray* details = @[@"  ",[NSString stringWithFormat:@"AuthToken: %@",cc.authToken]];
        
        return [details componentsJoinedByString:@"\n"];
                             
    }  else {
        return @"unknown";
    }
}



- (NSString*) humandValidForPI:(PLVPaymentInstrument*)pi {
    
    NSString* shortType = pi.type;
    
    if([shortType isEqualToString:@"CC"]) {
        PLVPayInstrumentCC* cc = (PLVPayInstrumentCC*)pi;
        return [NSString stringWithFormat:@"%@/%@",cc.expiryMonth,cc.expiryYear];
    } else {
        return @"";
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return TRUE;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.indexPathToDelete = [indexPath copy];

        [self deletePaymentInstrument];

    }
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:indexPath.row];

    UIAlertController* detailsAlertController = [UIAlertController alertControllerWithTitle:[self humanTypeForShort:pi.type] message:[self humanDetailsForPI:pi] preferredStyle:UIAlertControllerStyleAlert];
    
    if (detailsAlertController != Nil) {

        UIAlertAction* destroyAction = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *hideDetails) {
                                                   // do destructive stuff here
                                                   
                                                   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                                               }];

        [detailsAlertController addAction:destroyAction];
        
        [detailsAlertController setModalPresentationStyle:UIModalPresentationPopover];

        [self presentViewController:detailsAlertController animated:YES completion:Nil];
        
    } else {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        });
    }
}


- (IBAction)enterEditMode:(id)sender {
    
    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self.tableView setEditing:NO animated:YES];
        [self.editTableButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else {
        [self.editTableButton setTitle:@"Done" forState:UIControlStateNormal];
        
        // Turn on edit mode
        
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    
    if (self.automaticReOrder) {
        self.automaticReOrder = FALSE;
        return;
    }
    
    if (fromIndexPath.row == toIndexPath.row) {
        return;
    }
    
    self.indexPathFromOrder = [fromIndexPath copy];
    self.indexPathToOrder = [toIndexPath copy];
    
    PLVPaymentInstrument *piReOrderItem = [self.payInstruments objectAtIndex:fromIndexPath.row];
    
    NSMutableArray* tempOrder = [NSMutableArray arrayWithArray:self.payInstruments];
    
    [tempOrder  removeObject:piReOrderItem];

    [tempOrder  insertObject:piReOrderItem atIndex:toIndexPath.row];
    
    self.activityPlane.hidden = FALSE;
    
    NSOrderedSet* ordedSet = [[NSOrderedSet alloc] initWithArray:tempOrder];
    
    [[PLVInAppClient sharedInstance] setPaymentInstrumentsOrder:ordedSet forUserToken:self.userToken withUseCase:self.useCase andCompletion:^(NSDictionary* result, NSError* error){
        
        if (error != Nil ) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Oh NO" otherButtonTitles:nil];
            
            [alertView show];
            
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            
            if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                
                self.payInstruments = tempOrder;
            } else {
                
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"ReOrder" message:[NSString stringWithFormat:@"Error: %@", [result objectForKey:@"description"]] delegate:self cancelButtonTitle:@"Oh NO" otherButtonTitles:nil];
                
                [alertView show];

                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToOrder]
                                 withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathFromOrder] withRowAnimation:UITableViewRowAnimationLeft];
                // update your dataSource as well.
                [self.tableView endUpdates];
                
            }
        }
        
        self.activityPlane.hidden = TRUE;
        
    }];

}

- (void) deletePaymentInstrument {
    
    NSString* message = [NSString stringWithFormat:@"Disable PI or\nremove from %@ useCase?", self.useCase];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Disable or Remove" message:message delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Disable",@"Remove UseCsae",nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        // disable PI
        
        if (self.indexPathToDelete == Nil   ) {
            return;
        }
        
        self.activityPlane.hidden = FALSE;
        
        PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
        
        [[PLVInAppClient sharedInstance] disablePaymentInstrument:pi forUserToken:self.userToken andCompletion:^(NSDictionary* result, NSError* error){
            
            if (error != Nil ) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Oh NO" otherButtonTitles:nil];
                
                [alertView show];
                
            } else if ([result isKindOfClass:[NSDictionary class]]) {
                
                if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                    
                    NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.payInstruments];
                    
                    [newArray removeObjectAtIndex:self.indexPathToDelete.row];
                    
                    self.payInstruments = newArray;
                    // Animate the deletion
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
                    
                    // Additional code to configure the Edit Button, if any
                    if (self.payInstruments.count == 0) {
                        self.editTableButton.enabled = NO;
                        self.editTableButton.titleLabel.text = @"Edit";
                    }
                    
                }
            }
        
            self.activityPlane.hidden = TRUE;
            self.indexPathToDelete = Nil;
        
        }];
    } else if (buttonIndex == 2) {
        
        // remove useCase for PI
        
        if (self.indexPathToDelete == Nil   ) {
            return;
        }
        
        self.activityPlane.hidden = FALSE;
        
        PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
        
        [[PLVInAppClient sharedInstance] removePaymentInstrument:pi fromUseCase:self.useCase forUserToken:self.userToken andCompletion:^(NSDictionary* result, NSError* error){
            
            if (error != Nil ) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Oh NO" otherButtonTitles:nil];
                
                [alertView show];
                
            } else if ([result isKindOfClass:[NSDictionary class]]) {
                
                if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
                    
                    NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.payInstruments];
                    
                    [newArray removeObjectAtIndex:self.indexPathToDelete.row];
                    
                    self.payInstruments = newArray;
                    // Animate the deletion
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
                    
                    // Additional code to configure the Edit Button, if any
                    if (self.payInstruments.count == 0) {
                        self.editTableButton.enabled = NO;
                        self.editTableButton.titleLabel.text = @"Edit";
                    }
                    
                }
            }
            
            self.activityPlane.hidden = TRUE;
            self.indexPathToDelete = Nil;
            
        }];
    } else if (buttonIndex == 0){
        
        // cancel edit
        
        if (self.indexPathToDelete == Nil   ) {
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
        });
        

    }
}

@end



