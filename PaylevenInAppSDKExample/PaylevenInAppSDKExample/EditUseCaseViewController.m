//
//  EditUseCaseViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 09.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "EditUseCaseViewController.h"

#define useCaseTableViewCell @"useCaseTableViewCell"


@interface EditUseCaseViewController ()

@property (strong) IBOutlet UITableView* useCaseTable;
@property (weak) IBOutlet UIButton* editTableButton;
@property (weak) IBOutlet UITextField* addUseCaseTextField;
@property (weak) IBOutlet UIButton* addUseCaseButton;

@end

@implementation EditUseCaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.useCaseTable registerClass:[UITableViewCell class] forCellReuseIdentifier:useCaseTableViewCell];
    
    [self loadUseCases];
    
    [self.useCaseTable reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:useCaseTableViewCell forIndexPath:indexPath];
    
    cell.textLabel.text = [self.useCases objectAtIndex:indexPath.row];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.useCases.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.useCases objectAtIndex:indexPath.row] isEqualToString:@"DEFAULT"]) {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return TRUE;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSMutableArray* newUseCases = [NSMutableArray arrayWithArray:self.useCases];
    
    NSString* movingUseCase = [newUseCases objectAtIndex:fromIndexPath.row];

    [newUseCases removeObject:movingUseCase];
    
    [newUseCases insertObject:movingUseCase atIndex:toIndexPath.row];
    
    self.useCases = newUseCases;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.useCases forKey:@"allUseCase"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray* newUseCases = [NSMutableArray arrayWithArray:self.useCases];
        
        [newUseCases removeObjectAtIndex:indexPath.row];
        
        self.useCases = newUseCases;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.useCases forKey:@"allUseCase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.useCaseTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (self.useCases.count == 1) {
            [self.useCaseTable setEditing:NO animated:YES];
            [self.editTableButton setTitle:@"Edit" forState:UIControlStateNormal];
        }

    }
}

- (IBAction)enterEditMode:(id)sender {
    
    if (self.useCases.count < 2) {
        return;
    }
    
    if ([self.useCaseTable isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self.useCaseTable setEditing:NO animated:YES];
        [self.editTableButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else {
        [self.editTableButton setTitle:@"Done" forState:UIControlStateNormal];
        
        // Turn on edit mode
        
        [self.useCaseTable setEditing:YES animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* replacedString = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
    
    if (replacedString.length > 0 && ![replacedString isEqualToString:@"DEFAULT"]) {
        
        self.addUseCaseButton.enabled = TRUE;
        self.addUseCaseButton.alpha = 1.0;
        
        for (NSString* useCase in self.useCases) {
            
            if ([[useCase uppercaseString] isEqualToString:replacedString]) {
                // arghhh duplicate
                self.addUseCaseButton.enabled = FALSE;
                self.addUseCaseButton.alpha = .5;
            }
        }
    } else {
        self.addUseCaseButton.enabled = FALSE;
        self.addUseCaseButton.alpha = .5;
    }
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return TRUE;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
}

- (IBAction)addUseCase:(id)sender {
    
    NSMutableArray* newUseCases = [NSMutableArray arrayWithArray:self.useCases];
    
    [newUseCases addObject:self.addUseCaseTextField.text];
    
    self.useCases = newUseCases;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.useCases forKey:@"allUseCase"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSIndexPath* newPath = [NSIndexPath indexPathForRow:self.useCases.count -1 inSection:0];
    
    [self.useCaseTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationFade];
    
    self.addUseCaseButton.enabled = FALSE;
    self.addUseCaseButton.alpha = .5;
    self.addUseCaseTextField.text = @"";
    
    [self.addUseCaseTextField resignFirstResponder];
    
}

@end
