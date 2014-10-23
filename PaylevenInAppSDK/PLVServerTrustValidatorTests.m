//
//  PLVServerTrustValidatorTests.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 09.10.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;
@import XCTest;

#import "PLVServerTrustValidator.h"


@interface PLVServerTrustValidatorTests : XCTestCase

@property (nonatomic, strong) PLVServerTrustValidator *validator;
@property (nonatomic, strong) NSData *paylevenCertificateData;
@property (nonatomic, strong) NSData *intermediateCertificate1Data;
@property (nonatomic, assign) SecTrustRef paylevenServerTrust;

// The ownership is passed to the caller.
- (SecTrustRef)createPaylevenServerTrust;

// The ownership is passed to the caller.
- (SecTrustRef)createWikipediaServerTrust;

@end


@implementation PLVServerTrustValidatorTests

- (void)setUp {
    [super setUp];
    
    self.validator = [[PLVServerTrustValidator alloc] init];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"payleven-leaf" withExtension:@"cer"];
    assert(URL != nil);
    self.paylevenCertificateData = [NSData dataWithContentsOfURL:URL];
    assert(self.paylevenCertificateData != nil);
    
    URL = [bundle URLForResource:@"payleven-intermediate-1" withExtension:@"cer"];
    assert(URL != nil);
    self.intermediateCertificate1Data = [NSData dataWithContentsOfURL:URL];
    assert(self.intermediateCertificate1Data != nil);
    
    self.paylevenServerTrust = [self createPaylevenServerTrust];
    assert(self.paylevenServerTrust != NULL);
}

- (void)tearDown {
    self.validator = nil;
    self.paylevenCertificateData = nil;
    self.intermediateCertificate1Data = nil;
    CFRelease(self.paylevenServerTrust);
    
    [super tearDown];
}


#pragma mark -

- (SecTrustRef)createPaylevenServerTrust {
    NSMutableArray *certificates = [NSMutableArray array];
    id certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault,
                                                                        (__bridge CFDataRef)self.paylevenCertificateData);
    assert(certificates != nil);
    [certificates addObject:certificate];
    
    certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault,
                                                                     (__bridge CFDataRef)self.intermediateCertificate1Data);
    assert(certificate != nil);
    [certificates addObject:certificate];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"payleven-intermediate-2" withExtension:@"cer"];
    assert(URL != nil);
    NSData *data = [NSData dataWithContentsOfURL:URL];
    assert(data != nil);
    certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    assert(certificate != nil);
    [certificates addObject:certificate];
    
    URL = [bundle URLForResource:@"payleven-root" withExtension:@"cer"];
    assert(URL != nil);
    data = [NSData dataWithContentsOfURL:URL];
    assert(data != nil);
    certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    assert(certificate != nil);
    [certificates addObject:certificate];
    
    SecPolicyRef policy = SecPolicyCreateSSL(TRUE, CFSTR("anything.payleven.de"));
    assert(policy != NULL);
    
    SecTrustRef trust;
    SecTrustCreateWithCertificates((__bridge CFArrayRef)certificates, policy, &trust);
    assert(trust != NULL);
    
    // Set date within the leaf certificate valid date range (26.09.14-26.12.15).
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    components.month = 10;
    components.year = 2014;
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:components];
    OSStatus status = SecTrustSetVerifyDate(trust, (__bridge CFDateRef)date);
    assert(status == errSecSuccess);
    
    CFRelease(policy);
    
    return trust;
}

- (SecTrustRef)createWikipediaServerTrust {
    NSMutableArray *certificates = [NSMutableArray array];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"wikipedia-leaf" withExtension:@"cer"];
    assert(URL != nil);
    NSData *data = [NSData dataWithContentsOfURL:URL];
    assert(data != nil);
    id certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    assert(certificate != nil);
    [certificates addObject:certificate];
    
    URL = [bundle URLForResource:@"wikipedia-intermediate" withExtension:@"cer"];
    assert(URL != nil);
    data = [NSData dataWithContentsOfURL:URL];
    assert(data != nil);
    certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    assert(certificate != nil);
    [certificates addObject:certificate];
    
    URL = [bundle URLForResource:@"wikipedia-root" withExtension:@"cer"];
    assert(URL != nil);
    data = [NSData dataWithContentsOfURL:URL];
    assert(data != nil);
    certificate = (__bridge_transfer id)SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    assert(certificate != nil);
    [certificates addObject:certificate];
    
    SecPolicyRef policy = SecPolicyCreateSSL(TRUE, CFSTR("www.wikipedia.org"));
    assert(policy != NULL);
    
    SecTrustRef trust;
    SecTrustCreateWithCertificates((__bridge CFArrayRef)certificates, policy, &trust);
    assert(trust != NULL);
    
    // Set date within the leaf certificate valid date range (26.09.14-26.12.15).
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    components.month = 10;
    components.year = 2014;
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:components];
    OSStatus status = SecTrustSetVerifyDate(trust, (__bridge CFDateRef)date);
    assert(status == errSecSuccess);
    
    CFRelease(policy);
    
    return trust;
}


#pragma mark -

- (void)testValidationSucceedsWithCorrectCertificate {
    BOOL success = [self.validator validateServerTrust:self.paylevenServerTrust
                          withPublicKeyFromCertificate:self.paylevenCertificateData];
    XCTAssertTrue(success, @"Validation of server trust with correct certificate must succeed");
}

- (void)testValidationFailsWithIncorrectCertificate {
    BOOL success = [self.validator validateServerTrust:self.paylevenServerTrust
                          withPublicKeyFromCertificate:self.intermediateCertificate1Data];
    XCTAssertFalse(success, @"Validation of server trust with incorrect certificate must fail");
}

- (void)testValidationSucceedsWithOldCorrectCertificate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"payleven-leaf-old" withExtension:@"cer"];
    assert(URL != nil);
    NSData *data = [NSData dataWithContentsOfURL:URL];
    assert(data != nil);
    
    BOOL success = [self.validator validateServerTrust:self.paylevenServerTrust withPublicKeyFromCertificate:data];
    XCTAssertTrue(success, @"Validation of server trust with old correct certificate must succeed");
}

- (void)testValidationFailsWithIncorrectServerTrust {
    SecTrustRef trust = [self createWikipediaServerTrust];
    BOOL success = [self.validator validateServerTrust:trust withPublicKeyFromCertificate:self.paylevenCertificateData];
    CFRelease(trust);
    XCTAssertFalse(success, @"Validation of incorrect server trust must fail");
}

@end
