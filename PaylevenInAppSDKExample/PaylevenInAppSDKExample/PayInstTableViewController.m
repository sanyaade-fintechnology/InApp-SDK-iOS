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
@property (strong) NSArray* payInstruments;
@property (strong) NSString* userToken;
@property (strong) NSIndexPath* indexPathToDelete;

@end

@implementation PayInstTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib* cellNib = [UINib nibWithNibName:@"PayInstrumentsTableCell" bundle:Nil];
    
    
    [self.tableView registerNib:cellNib forCellReuseIdentifier:piLiastTableViewCell];
    
    [self.tableView reloadData];
}

- (IBAction)backButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPIArray:(NSArray*)piArray forUserToken:(NSString*)userToken {
    
    self.userToken = userToken;
    self.payInstruments = piArray;
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
        return cc.accountNumber;
    } else if([shortType isEqualToString:@"SEPA"]) {
        PLVPayInstrumentSEPA* cc = (PLVPayInstrumentSEPA*)pi;
        return [NSString stringWithFormat:@"IBAN:%@",cc.iban];
    } else if([shortType isEqualToString:@"PAYPAL"]) {
        PLVPayInstrumentPAYPAL* cc = (PLVPayInstrumentPAYPAL*)pi;
        return [NSString stringWithFormat:@"PAYPAYL:%@",cc.emailAddress];
    }  else {
        return @"unknown";
    }
    
}

- (NSString*) humandValidForPI:(PLVPaymentInstrument*)pi {
    
    NSString* shortType = pi.type;
    
    if([shortType isEqualToString:@"CC"]) {
        PLVPayInstrumentCC* cc = (PLVPayInstrumentCC*)pi;
        return [NSString stringWithFormat:@"%@/%@",cc.expiryMonth,cc.expiryYear];
    } else if([shortType isEqualToString:@"DD"]) {
        PLVPayInstrumentDD* cc = (PLVPayInstrumentDD*)pi;
        return [NSString stringWithFormat:@"%@/%@",cc.expiryMonth,cc.expiryYear];
    } else if([shortType isEqualToString:@"SEPA"]) {
        PLVPayInstrumentSEPA* cc = (PLVPayInstrumentSEPA*)pi;
        return [NSString stringWithFormat:@"%@/%@",cc.expiryMonth,cc.expiryYear];
    } else if([shortType isEqualToString:@"PAYPAL"]) {

        return @"";
    }  else {
        return @"unknown";
    }
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        self.indexPathToDelete = [indexPath copy];
        
        PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:indexPath.row];
        
        [self deletePaymentInstrument];

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

- (void) deletePaymentInstrument {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Disable" message:@"Really Disable PaymentInstrument??" delegate:self cancelButtonTitle:@"Oh NO" otherButtonTitles:@"Disable",nil];
    
    [alertView show];
    
}

- (void) displayAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Oh NO" otherButtonTitles:@"Disable",nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        if (self.indexPathToDelete == Nil   ) {
            return;
        }
        
        self.activityPlane.hidden = FALSE;
        
        PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:self.indexPathToDelete.row];
        
        [[PLVInAppClient sharedInstance] disablePaymentInstruments:[NSArray arrayWithObject:pi] forUserToken:self.userToken withCompletion:^(NSDictionary* result, NSError* error){
            
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
    }
}

@end



