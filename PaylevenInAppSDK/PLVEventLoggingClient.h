//
//  PLVEventLoggingClient.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 11/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/**
 * PLVEventLogginClient is responsible for sending network requests to Payleven server.
 *
 * PLVEventLogginClient is thread-safe. Its methods can be called from any thread or queue.
 */
@interface PLVEventLoggingClient : NSObject

/** Serial queue the receiver operates on. */
@property(nonatomic, readonly, strong) NSOperationQueue *queue;

/** Initializes the receiver with the queue. */
- (instancetype)initWithQueue:(NSOperationQueue *)queue andDelegate:(id <NSURLSessionDelegate>)delegate;

/** Sends events. The completion block will be executed on the queue specified during the initialization. */
- (void)sendEvents:(NSArray *)events completionHandler:(void (^)(BOOL success))completionHandler;

@end
