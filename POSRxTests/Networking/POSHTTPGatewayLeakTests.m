//
//  POSHTTPGatewayLeakTests.m
//  POSRx
//
//  Created by Osipov on 10.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@interface POSHTTPGatewayLeakTests : XCTestCase
@property (nonatomic) POSHTTPGateway *gateway;
@end

@implementation POSHTTPGatewayLeakTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSHTTPGateway.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testHTTPGatewayLeaksAbsense {
    self.gateway = [[POSHTTPGateway alloc]
                    initWithScheduler:[RACScheduler mainThreadScheduler]
                    backgroundSessionIdentifier:@"com.github.pavelosipov.HTTPGatewayTests"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *responseData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    POSHTTPRequestExecutionOptions *options = [POSHTTPRequestExecutionOptions new];
    options.simulation = [POSHTTPRequestSimulationOptions new];
    options.simulation.rate = 1.0f;
    options.simulation.responses = @{[[POSHTTPResponse alloc] initWithData:responseData]: @(1)};
    id<POSHTTPTask> task = [_gateway dataTaskWithRequest:[POSHTTPRequest new]
                                                  toHost:hostURL
                                                 options:options];
    [task.executing subscribeNext:^(NSNumber *executing) {
        if (!executing.boolValue) {
            [[_gateway invalidateCancelingTasks:YES] subscribeCompleted:^{
                self.gateway = nil;
                [[RACScheduler mainThreadScheduler] afterDelay:0.01 schedule:^{
                    [expectation fulfill];
                }];
            }];
        }
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
