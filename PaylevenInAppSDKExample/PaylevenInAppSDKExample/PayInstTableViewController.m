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

@property (strong) NSArray* payInstruments;

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

- (void) setPIArray:(NSArray*)piArray {
    
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

@end



