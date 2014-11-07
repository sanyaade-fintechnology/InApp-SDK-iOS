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

@interface PayInstTableViewController ()

@property (weak) IBOutlet UITableView* tableView;

@property (strong) NSArray* payInstruments;

@end

@implementation PayInstTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:piLiastTableViewCell];
    
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:piLiastTableViewCell forIndexPath:indexPath];
    
    PLVPaymentInstrument* pi = [self.payInstruments objectAtIndex:indexPath.row];
    
    cell.textLabel.text = pi.identifier;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.payInstruments.count;
}
@end
