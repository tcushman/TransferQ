//
//  TransferQ.m
//  TransferQ
//
//  Created by Ted Cushman on 6/25/15.
//  Copyright (c) 2015 Home Spotter. All rights reserved.
//

#import "TransferQ.h"
@import Dispatch;

@implementation TransferQ

- (TransferQ*) init {
    self = [super init];
    if (self) {
        offerSem = dispatch_semaphore_create(0);
        takeSem = dispatch_semaphore_create(0);
    }
    return self;
}

- (BOOL) offer: (id)value timeout:(int64_t)timeout {
    int64_t nanos = timeout * 1000000;
    long t = dispatch_semaphore_wait(takeSem, dispatch_time(DISPATCH_TIME_NOW, nanos));
    if (0 == t) {
        v = value;
        dispatch_semaphore_signal(offerSem);
        return true;
    }
    return false;
}

- (id)take:(int64_t)timeout onTimeout:(id)timedOutValue {
    int64_t nanos = timeout * 1000000;
    dispatch_semaphore_signal(takeSem);
    long o = dispatch_semaphore_wait(offerSem, dispatch_time(DISPATCH_TIME_NOW, nanos));
    if (0 == o) {
        id value = v;
        v = NULL;
        return value;
    }
    return timedOutValue;
}

- (id) take: (int64_t)timeout {
    return [self take:timeout onTimeout:NULL];
}

@end
