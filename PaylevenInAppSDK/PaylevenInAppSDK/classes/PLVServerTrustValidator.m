//
//  PLVServerTrustValidator.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 09.10.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVServerTrustValidator.h"


@interface PLVServerTrustValidator ()

/** Performs normal validation for the specified server trust. */
- (BOOL)validateServerTrust:(SecTrustRef)serverTrust;

/**
 * Returns public key from the specified DER-encoded certificate represented as NSData.
 *
 * @discussion
 * The real type of the returned object is @c SecKeyRef. As a convenience, it's bridged to @c id with transfer ownership
 * to ARC.
 */
- (id)publicKeyFromCertificate:(NSData *)certificateData;

@end


@implementation PLVServerTrustValidator

- (BOOL)validateServerTrust:(SecTrustRef)serverTrust withPublicKeyFromCertificate:(NSData *)certificateData {
    BOOL result = NO;
    
    if ([self validateServerTrust:serverTrust]) {
        // SecTrustEvaluate() must be called at this point. That's what -validateServerTrust: does.
        id publicKey = (__bridge_transfer id)SecTrustCopyPublicKey(serverTrust);
        if (publicKey == NULL) {
            NSLog(@"Error getting public key from trust during server trust validation");
        } else {
            id allowedPublicKey = [self publicKeyFromCertificate:certificateData];
            result = [publicKey isEqual:allowedPublicKey];
        }
    }
    
    return result;
}


#pragma mark -

- (BOOL)validateServerTrust:(SecTrustRef)serverTrust {
    BOOL isValid = NO;
    SecTrustResultType evaluationResult;
    OSStatus status = SecTrustEvaluate(serverTrust, &evaluationResult);
    if (status == errSecSuccess) {
        isValid = evaluationResult == kSecTrustResultUnspecified || evaluationResult == kSecTrustResultProceed;
    } else {
        NSLog(@"Error evaluating server trust: %d", (int)status);
    }
    
    return isValid;
}

- (id)publicKeyFromCertificate:(NSData *)certificateData {
    id publicKey = NULL;
    SecCertificateRef certificate = NULL;
    SecPolicyRef policy = NULL;
    SecTrustRef trust = NULL;
    OSStatus status;
    
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData);
    if (certificate == NULL) {
        goto _out;
    }
    
    policy = SecPolicyCreateBasicX509();
    status = SecTrustCreateWithCertificates(certificate, policy, &trust);
    if (status != errSecSuccess) {
        NSLog(@"Error creating trust when extracting public key from certificate: %d", (int)status);
        goto _out;
    }
    
    // We're not interested in the evaluation result. This function must be called before calling SecTrustCopyPublicKey().
    status = SecTrustEvaluate(trust, NULL);
    if (status != errSecSuccess) {
        NSLog(@"Error evaluating trust when extracting public key from certificate: %d", (int)status);
        goto _out;
    }
    
    publicKey = (__bridge_transfer id)SecTrustCopyPublicKey(trust);
    if (publicKey == NULL) {
        NSLog(@"Error getting public key from trust when extracting public key from certificate");
        goto _out;
    }
    
_out:
    if (trust != NULL) {
        CFRelease(trust);
    }
    if (policy != NULL) {
        CFRelease(policy);
    }
    if (certificate != NULL) {
        CFRelease(certificate);
    }
    
    return publicKey;
}

@end
