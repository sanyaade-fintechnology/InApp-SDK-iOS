//
//  PLVHTTPUserAgent.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 07/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/** Payleven SDK HTTP user agent. */
@interface PLVHTTPUserAgent : NSObject

/** Returns user agent string. */
+ (NSString *)userAgentString;

@end
