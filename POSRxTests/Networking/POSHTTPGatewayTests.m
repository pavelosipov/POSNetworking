//
//  POSHTTPGatewayTests.m
//  POSRx
//
//  Created by Pavel Osipov on 09.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@interface POSHTTPGatewayTests : XCTestCase
@property (nonatomic) POSHTTPGateway *gateway;
@end

@implementation POSHTTPGatewayTests

- (void)setUp {
    [super setUp];
    self.gateway = [[POSHTTPGateway alloc]
                    initWithScheduler:[RACScheduler mainThreadScheduler]
                    backgroundSessionIdentifier:@"com.github.pavelosipov.HTTPGatewayTests"];
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testResponseSimulation {
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
    [task.values subscribeNext:^(POSHTTPResponse *response) {
        XCTAssertTrue(response.metadata.statusCode == 200);
        XCTAssertEqualObjects(response.metadata.URL, hostURL);
        XCTAssertEqualObjects(response.data, responseData);
        [expectation fulfill];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
