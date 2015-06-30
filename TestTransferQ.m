//
//  TestTransferQ.m
//  TransferQ
//
//  Created by Ted Cushman on 6/25/15.
//  Copyright (c) 2015 Home Spotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TransferQ.h"
@import Dispatch;

@interface TestTransferQ : XCTestCase

@end

@implementation TestTransferQ

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    TransferQ *tq = [[TransferQ alloc] init];
    XCTAssertNotNil(tq);
}

- (void)testTransferOneWay {
    TransferQ *xferq = [[TransferQ alloc] init];

    dispatch_queue_t dq = dispatch_queue_create("Test Queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(dq, ^{
        NSLog(@"BG: Offering value...");
        XCTAssertTrue( [xferq offer:@"foo" timeout:5] );
    });

    NSLog(@"FG: Awaiting value...");
    id received = [xferq take:5];
    NSLog(@"FG: Received value: %@", received);
    XCTAssertEqualObjects(@"foo", received);
}

- (void)testTransferRoundTrip {
    TransferQ *xferq = [[TransferQ alloc] init];

    dispatch_queue_t dq = dispatch_queue_create("Test Queue", DISPATCH_QUEUE_SERIAL);

    dispatch_async(dq, ^{
        NSLog(@"BG: Waiting for value...");
        id in = [xferq take:10];
        NSLog(@"BG: Received value: '%@'", in);

        [NSThread sleepForTimeInterval:0.005f];
        [xferq offer:in timeout:10];
        NSLog(@"BG: Sent value: '%@'", in);
    });

    id payload = @"foo";

    [NSThread sleepForTimeInterval:0.005f];
    NSLog(@"FG: Sending value: '%@'", payload);
    [xferq offer:payload timeout:10];

    [NSThread sleepForTimeInterval:0.005f];
    NSLog(@"FG: Awaiting response...");
    id out = [xferq take:10];
    NSLog(@"FG: Received response: %@", out);

    XCTAssertEqual(payload, out);
}

- (void)testTransferThreeParties {
    TransferQ *xferq = [[TransferQ alloc] init];

    dispatch_queue_t dq = dispatch_queue_create("Test Queue", DISPATCH_QUEUE_SERIAL);

    dispatch_async(dq, ^{
        NSLog(@"BG1: Waiting for value...");
        id in = [xferq take:10];
        NSLog(@"BG1: Received value: '%@'", in);
        
        [NSThread sleepForTimeInterval:0.005f];
        XCTAssertTrue( [xferq offer:in timeout:10] );
        NSLog(@"BG1: Sent value: '%@'", in);
    });

    dispatch_async(dq, ^{
        NSLog(@"BG2: Waiting for value...");
        id in = [xferq take:10];
        NSLog(@"BG2: Received value: '%@'", in);
        
        [NSThread sleepForTimeInterval:0.005f];
        XCTAssertTrue( [xferq offer:in timeout:10] );
        NSLog(@"BG2: Sent value: '%@'", in);
    });

    id payload1 = @"foo";
    id payload2 = @"bar";

    NSLog(@"FG: Sending first value: '%@'", payload1);
    XCTAssertTrue( [xferq offer:payload1 timeout:10] );
    id out1 = [xferq take:10];
    XCTAssertEqual( payload1, out1 );

    NSLog(@"FG: Sending second value: '%@'", payload2);
    XCTAssertTrue( [xferq offer:payload2 timeout:10] );
    id out2 = [xferq take:10];

    XCTAssertEqual( payload2, out2 );
}

- (void)testTakeTimeout {
    TransferQ *xferq = [[TransferQ alloc] init];
    XCTAssertNil( [xferq take:1] );

    id incomplete = @"Failed";
    XCTAssertEqualObjects( incomplete, [xferq take:1 onTimeout:incomplete] );
}

- (void)testOfferTimeout {
    TransferQ *xferq = [[TransferQ alloc] init];
    XCTAssertFalse( [xferq offer:@"Hello" timeout:1] );
}

- (void)testMissedTransfer {
    TransferQ *xferq = [[TransferQ alloc] init];
    XCTAssertFalse( [xferq offer:@"Hello" timeout:1] );

    id incomplete = @"Failed";
    XCTAssertEqualObjects( incomplete, [xferq take:1 onTimeout:incomplete] );
}

@end
