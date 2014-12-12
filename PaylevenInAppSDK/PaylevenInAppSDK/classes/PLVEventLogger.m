//
//  PLVEventLogger.m
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 06/11/14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

#import "PLVEventLogger.h"

@import UIKit;

#import "PLVEventLoggingClient.h"


@interface PLVEventLogger ()

/** Gathered events. */
@property(nonatomic, readonly, strong) NSMutableArray *events;

/** Batch timer. */
@property(nonatomic, strong) NSTimer *timer;

/** Sets up the timer. */
- (void)setupTimer;

/** Timer tick. */
- (void)timerTick:(NSTimer *)timer;

/** Sends pending events. */
- (void)sendPendingEvents;

/** Sends the specified events. */
- (void)sendEvents:(NSArray *)events;

/** Handles succesful send of events. */
- (void)didSendEvents:(NSArray *)events;

/** Handles event send failure. */
- (void)didFailSendingEvents:(NSArray *)events;

@end


@implementation PLVEventLogger

- (instancetype)initWithQueue:(NSOperationQueue *)queue
           eventLoggingClient:(PLVEventLoggingClient *)eventLoggingClient
                 timeInterval:(NSTimeInterval)timeInterval {
    
    if (queue.maxConcurrentOperationCount != 1) {
        @throw [NSException exceptionWithName:@"PLVBadInitCall"
                                       reason:@"The queue must be serial"
                                     userInfo:nil];
        return nil;
    }
    
    self = [super init];
    if (self != nil) {
        _queue = queue;
        _eventLoggingClient = eventLoggingClient;
        _timeInterval = timeInterval;
        _events = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark -

- (void)logEvent:(PLVEvent *)event {
    if (event != nil) {
        [self.queue addOperationWithBlock:^{
            [self _logEvent:event];
        }];
    }
}

- (void)_logEvent:(PLVEvent *)event {
    assert([[NSOperationQueue currentQueue] isEqual:self.queue]);
    [self.events addObject:event];
    [self setupTimer];
}


#pragma mark - Private

- (void)setupTimer {
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:self.timeInterval
                                             target:self
                                           selector:@selector(timerTick:)
                                           userInfo:nil
                                            repeats:NO];
        self.timer.tolerance = self.timeInterval / 10.0;
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)timerTick:(NSTimer *)timer {
    [self sendPendingEvents];
}

- (void)sendPendingEvents {
    [self.queue addOperationWithBlock:^{
        if (self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
        [self sendEvents:[self.events copy]];
    }];
}

- (void)sendEvents:(NSArray *)events {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask
        = [application beginBackgroundTaskWithName:@"Send Events" expirationHandler:^{
            [application endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }];
    [self.eventLoggingClient sendEvents:events completionHandler:^(BOOL success) {
        if (success) {
            [self didSendEvents:events];
        } else {
            [self didFailSendingEvents:events];
        }
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
}

- (void)didSendEvents:(NSArray *)events {
    assert([[NSOperationQueue currentQueue] isEqual:self.queue]);
    [self.events removeObjectsInArray:events];
}

- (void)didFailSendingEvents:(NSArray *)events {
    assert([[NSOperationQueue currentQueue] isEqual:self.queue]);
    [self setupTimer];
}

@end
