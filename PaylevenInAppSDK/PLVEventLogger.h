//
//  PLVEventLogger.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 06/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

@class PLVEvent, PLVEventLoggingClient;

/**
 * PLVEventLogger logs events via the network.
 *
 * The event logger doesn't send the event right away. It gathers all the events within the time interval specified
 * by @em timeInterval property. Gathering of events starts when the log method is called first time and stops when the
 * time interval expires. Then all gathered events are sent in one request.
 *
 * PLVEventLogger is thread-safe. Its methods can be called from any thread of queue.
 */
@interface PLVEventLogger : NSObject

/** Serial queue the receiver operates on. */
@property(nonatomic, readonly, strong) NSOperationQueue *queue;

/** Event logging network client. */
@property(nonatomic, readonly, strong) PLVEventLoggingClient *eventLoggingClient;

/** Time interval for sending log batches. */
@property(nonatomic, readonly, assign) NSTimeInterval timeInterval;

/** Initializes the receiver with the specified queue, event logging client, and time interval. */
- (instancetype)initWithQueue:(NSOperationQueue *)queue
           eventLoggingClient:(PLVEventLoggingClient *)eventLoggingClient
                 timeInterval:(NSTimeInterval)timeInterval;

/**  Logs the specified event. */
- (void)logEvent:(PLVEvent *)event;

@end
