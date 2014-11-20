//
//  PLVRequestPersistManager.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 20.11.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#import "PLVRequestPersistManager.h"

#import "singletonHelper.h"



@implementation PLVRequestPersistManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVRequestPersistManager);

-(NSString*) encryptDecrypt:(NSString*)toEncrypt {
    
    char key = 'q'; //Any char will work
    
    const char* encryptChar = [toEncrypt UTF8String];
    
    char* output = (char*) [toEncrypt UTF8String];
    
    for (int i = 0; i < toEncrypt.length; i++)
        output[i] = encryptChar[i] ^ key;
    
    return [NSString stringWithUTF8String:output];
}

@end
