//
//  TransferQ.h
//  TransferQ
//
//  Created by Ted Cushman on 6/25/15.
//  Copyright (c) 2015 Home Spotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransferQ : NSObject {
@private
    dispatch_semaphore_t offerSem;
    dispatch_semaphore_t takeSem;
    volatile id v;
}

- (TransferQ *)init;

- (BOOL)offer:(id)value timeout:(int64_t)timeout;

- (id)take:(int64_t)timeout;

- (id)take:(int64_t)timeout onTimeout:(id)timedOutValue;

@end
