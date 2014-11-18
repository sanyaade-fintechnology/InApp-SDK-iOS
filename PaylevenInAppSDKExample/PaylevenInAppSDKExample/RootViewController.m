//
//  RootViewController.m
//  PaylevenInAppSDKExample
//
//  Created by ploenne on 20.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//


@import Foundation;

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "RootViewController.h"

#import <PaylevenInAppSDK/PLVInAppSDK.h>


#define kUserDefaultsBEIPKey @"backEndIP"

#define isIPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface RootViewController()

@property (strong) NSString* savedBEIP;
@property (weak) IBOutlet UITextField* backEndIPTextField;
@property (weak) IBOutlet UIButton* resetButton;
@property (weak) IBOutlet UIView* setBEipPanel;

@end


@implementation RootViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.savedBEIP = Nil;
    
    [self loadBackEndIP];
    
    if (self.savedBEIP != Nil) {
        self.backEndIPTextField.text = self.savedBEIP;
    }
    
    self.bundleIDLabel.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build: %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    self.registerAPIKeyButton.layer.cornerRadius = 5.f;
    self.registerAPIKeyButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.registerAPIKeyButton.layer.borderWidth = 1.f;
    
//    if ([[self getIPAddress] hasPrefix:@"10.15.100."]) {
//        
//        self.setBEipPanel.hidden = TRUE;
//    } else {
//        self.setBEipPanel.hidden = FALSE;
//    }
    
}

- (IBAction)longPress:(id)sender {

    self.savedBEIP = Nil;
    self.backEndIPTextField.text = @"Default";
    self.apiKeyTextField.text = @"4840bbc6429dacd56bfa98390ddf43";
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsBEIPKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)showSelectAPIKeyActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the API Key"
                                                             delegate:self
                                                    cancelButtonTitle:(isIPAD ? Nil : @"Cancel")
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"nAj6Rensh2Ew3Oc4Ic2gig1F", @"4840bbc6429dacd56bfa98390ddf43", @"462123efc681534108cf2b34b4f8fb", nil];
    
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            self.apiKeyTextField.text = @"nAj6Rensh2Ew3Oc4Ic2gig1F";
            break;
        case 1:
            self.apiKeyTextField.text = @"4840bbc6429dacd56bfa98390ddf43";
            break;
        case 2:
            self.apiKeyTextField.text = @"462123efc681534108cf2b34b4f8fb";
            break;
        default:
            break;
    }
    
}


- (IBAction) setAPIKey:(id)sender {
    
    [[PLVInAppClient sharedInstance] registerWithAPIKey:self.apiKeyTextField.text andSpecificBaseServiceURL: self.savedBEIP];
    
}


- (void) loadBackEndIP {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBEIPKey] isKindOfClass:[NSString class]]) {
        
        self.savedBEIP = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBEIPKey];
    
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length > 3) {
        
        self.savedBEIP = textField.text;
        
        if (![self.savedBEIP hasPrefix:@"http://"]) {
            self.savedBEIP = [NSString stringWithFormat:@"http://%@",self.savedBEIP];
        }
        
        
        if (![self.savedBEIP hasSuffix:@"/staging/api"]) {
            self.savedBEIP = [NSString stringWithFormat:@"%@/staging/api",self.savedBEIP];
        }
        
        
        textField.text = self.savedBEIP;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.savedBEIP forKey:kUserDefaultsBEIPKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [textField resignFirstResponder];
    
    return TRUE;
}


- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
