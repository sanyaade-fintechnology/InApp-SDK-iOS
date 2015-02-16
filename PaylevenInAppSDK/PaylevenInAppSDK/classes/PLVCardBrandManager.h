//
//  PLVCardBrandManager.h
//  PaylevenSDK
//
//  Created by ploenne on 12.12.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/** Class providing card brands. */
@interface PLVCardBrandManager : NSObject <NSURLSessionDelegate>


/**
 *  sharedInstance
 *
 *  @return Singleton PLVCardBrandManager
 */

+ (instancetype) sharedInstance;


- (void) setUpWithQueue:(NSOperationQueue *)queue;


/** our current cardBrands */
-(NSArray*) currentCardBrands;

@end
