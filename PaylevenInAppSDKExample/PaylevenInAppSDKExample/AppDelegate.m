//
//  AppDelegate.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "AppDelegate.h"

#import <PaylevenInAppSDK/PLVInAppSDK.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    

//    NSString* apiKey = @"462123efc681534108cf2b34b4f8fb";
//    NSString* apiKey = @"nAj6Rensh2Ew3Oc4Ic2gig1F";
    NSString* apiKey = @"4840bbc6429dacd56bfa98390ddf43";
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:apiKey];

    [[PLVInAppClient sharedInstance] getUserToken:@"test@test.de" withCompletion:^(NSDictionary* response, NSError* error) {
        
        if ([response objectForKey:@"userToken"]) {
            NSString* userToken = [response objectForKey:@"userToken"];
            
            PLVPayInstrumentCC* ccCard = [[PLVPayInstrumentCC alloc] init];
            
            
            ccCard.pan = [NSString stringWithFormat:@"%@%i%i",@"CCard",arc4random(),arc4random()];
            ccCard.expiryMonth = @"10";
            ccCard.expiryYear = @"16";
            
            [[PLVInAppClient sharedInstance] addPaymentInstruments:@[ccCard] forUserToken:userToken withCompletion:^(NSDictionary* response, NSError* error) {
            
                [[PLVInAppClient sharedInstance] listPaymentInstrumentsForUserToken:userToken withCompletion:^(NSDictionary* response, NSError* error) {
                    
                    
                }];
            
            }];
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
            
            });
            
        }
       
    }];
    

    
    
    
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
