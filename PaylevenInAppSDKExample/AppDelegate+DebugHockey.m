//
//  AppDelegate+DebugHockey.m
//  PaylevenInAppSDKExample
//
//  Created by Johannes Rupieper on 09/03/15.
//  Copyright (c) 2015 payleven. All rights reserved.
//

#import "AppDelegate+DebugHockey.h"
#import <HockeySDK/HockeySDK.h>

@implementation AppDelegate (DebugHockey)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString * crashReportHockeyId = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"Hockey_Crash_AppId"];
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"HOCKEY CRASH" message:crashReportHockeyId delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
    if (crashReportHockeyId) {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:crashReportHockeyId];
        [[BITHockeyManager sharedHockeyManager] startManager];
    }
    
    return YES;
}

@end
