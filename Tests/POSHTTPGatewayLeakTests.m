//
//  POSHTTPGatewayLeakTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 10.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSNetworking/POSNetworking.h>
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
                    initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                    backgroundSessionIdentifier:nil];
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *responseData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    POSHTTPGatewayOptions *options = [[POSHTTPGatewayOptions alloc]
        initWithRequestOptions:nil
        responseOptions:[[POSHTTPResponseOptions alloc]
            initWithRate:100
            responseSimulator:^POSHTTPResponse * (id<POSHTTPRequest> request, NSURL *URL, POSHTTPRequestOptions *_) {
                return [[POSHTTPResponse alloc] initWithData:responseData];
            }]];
    [[[_gateway
        taskForRequest:[POSHTTPGET build] toHost:hostURL options:options]
        execute]
        subscribeCompleted:^{
            [[self.gateway invalidateForced:YES] subscribeCompleted:^{
                self.gateway = nil;
                [[RACScheduler mainThreadScheduler] afterDelay:0.01 schedule:^{
                    [expectation fulfill];
                }];
            }];
        }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
