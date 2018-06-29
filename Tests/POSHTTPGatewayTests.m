//
//  POSHTTPGatewayTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 09.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <XCTest/XCTest.h>

@interface POSHTTPGatewayTests : XCTestCase
@property (nonatomic) POSHTTPGateway *gateway;
@end

@implementation POSHTTPGatewayTests

- (void)setUp {
    [super setUp];
    self.gateway = [[POSHTTPGateway alloc]
                    initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                    backgroundSessionIdentifier:@"com.github.pavelosipov.HTTPGatewayTests"];
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSHTTPRequest.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACSignal.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void)testHTTPGatewayResponseSimulation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *responseData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    POSHTTPRequestExecutionOptions *options =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:nil
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:1.0f
                        responses:@{[[POSHTTPResponse alloc] initWithData:responseData]: @(1)}]];
    [[[_gateway taskForRequest:[POSHTTPRequest new] toHost:hostURL options:options] execute] subscribeNext:^(POSHTTPResponse *response) {
        XCTAssertTrue(response.metadata.statusCode == 200);
        XCTAssertEqualObjects(response.metadata.URL, hostURL);
        XCTAssertEqualObjects(response.data, responseData);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHTTPGatewayStubbedResponse {
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *responseData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[responseData copy] statusCode:201 headers:nil];
    }];
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    [[[_gateway taskForRequest:[POSHTTPRequest new] toHost:hostURL options:nil] execute] subscribeNext:^(POSHTTPResponse *response) {
        XCTAssertTrue(response.metadata.statusCode == 201);
        XCTAssertEqualObjects(response.metadata.URL, hostURL);
        XCTAssertEqualObjects(response.data, responseData);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHTTPGatewayStubbedError {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSError* error = [NSError
                          errorWithDomain:NSURLErrorDomain
                          code:kCFURLErrorNotConnectedToInternet
                          userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    [[[_gateway taskForRequest:[POSHTTPRequest new] toHost:[hostURL copy] options:nil] execute] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.userInfo[NSURLErrorKey], hostURL);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHTTPGatewayPushesRequestWithoutSubscribers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *responseData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[responseData copy] statusCode:201 headers:nil];
    }];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    POSTask *task = [_gateway taskForRequest:[POSHTTPRequest new] toHost:hostURL options:nil];
    [task.values subscribeNext:^(POSHTTPResponse *response) {
        XCTAssertTrue(response.metadata.statusCode == 201);
        [expectation fulfill];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
