//
//  PLVServerCertificate.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 09.10.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/** Class representing Payleven server certificate. */
@interface PLVServerCertificate : NSObject

/** Certificate data. */
@property (nonatomic, readonly, strong) NSData *data;

@end
