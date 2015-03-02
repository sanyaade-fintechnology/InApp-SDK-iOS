//
//  UseCaseViewController.h
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 08.12.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>

#define selectUseCaseActionSheet 6768

@interface UseCaseViewController : UIViewController <UIActionSheetDelegate>


@property (strong) NSString* useCase;
@property (strong) NSArray* useCases;

- (void) loadUseCases;

@end
