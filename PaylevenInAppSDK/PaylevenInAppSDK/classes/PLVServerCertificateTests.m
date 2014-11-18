//
//  PLVServerCertificateTests.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 09.10.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import XCTest;

#import "PLVServerCertificate.h"


@interface PLVServerCertificateTests : XCTestCase

@property (nonatomic, strong) PLVServerCertificate *certificate;

@end


@implementation PLVServerCertificateTests

- (void)setUp {
    [super setUp];
    
    self.certificate = [[PLVServerCertificate alloc] init];
}

- (void)tearDown {
    self.certificate = nil;
    
    [super tearDown];
}

- (void)testCertificateData {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"payleven-leaf" withExtension:@"cer"];
    assert(URL != nil);
    NSData *paylevenLeafData = [NSData dataWithContentsOfURL:URL];
    assert(paylevenLeafData != nil);
    
    XCTAssertEqualObjects(self.certificate.data, paylevenLeafData, @"Certificate data must be equal");
}

@end
