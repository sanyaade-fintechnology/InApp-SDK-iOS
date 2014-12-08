//
//  UseCaseViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 08.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "UseCaseViewController.h"


#define kUserDefaultsCurrentUseCaseKey @"currentUseCase"
#define kUserDefaultsAllUseCasesKey @"allUseCase"
#define sheetCancelButtonIndex 666

@interface UseCaseViewController ()

@end

@implementation UseCaseViewController

- (IBAction)showUseCaseActionSheet:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    [self loadUseCases];
    
    for( NSString *title in self.useCases)  {
        [actionSheet addButtonWithTitle:title];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = self.useCases.count;
    actionSheet.tag = selectUseCaseActionSheet;
    actionSheet.delegate = self;
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == selectUseCaseActionSheet) {
        
        if (buttonIndex != self.useCases.count) {
            self.useCase = [self.useCases objectAtIndex:buttonIndex];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.useCases forKey:kUserDefaultsCurrentUseCaseKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void) loadUseCases {
    
    self.useCases = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsAllUseCasesKey];
    
    if (self.useCases != Nil) {
        self.useCases = @[@"DEFAULT",@"PRIVATE",@"BUSINESS"];
        [[NSUserDefaults standardUserDefaults] setObject:self.useCases forKey:kUserDefaultsAllUseCasesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.useCase = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCurrentUseCaseKey];

    if (![self.useCases  containsObject:self.useCase]) {
        if (self.useCases.count > 0 ) {
            self.useCase = [self.useCases firstObject];
        }
    }

}


@end
