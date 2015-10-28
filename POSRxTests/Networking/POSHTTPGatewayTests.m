//
//  POSHTTPGatewayTests.m
//  POSRx
//
//  Created by Pavel Osipov on 09.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
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
                    initWithScheduler:[RACScheduler mainThreadScheduler]
                    backgroundSessionIdentifier:@"com.github.pavelosipov.HTTPGatewayTests"];
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSHTTPRequest.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACMulticastConnection.class] == 0);
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
    [[_gateway pushRequest:[POSHTTPRequest new] toHost:hostURL options:options] subscribeNext:^(POSHTTPResponse *response) {
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
    [[_gateway pushRequest:[POSHTTPRequest new] toHost:hostURL options:nil] subscribeNext:^(POSHTTPResponse *response) {
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
    [[_gateway pushRequest:[POSHTTPRequest new] toHost:[hostURL copy] options:nil] subscribeError:^(NSError *error) {
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
        [[RACScheduler mainThreadScheduler] afterDelay:0.01 schedule:^{
            [expectation fulfill];
        }];
        return [OHHTTPStubsResponse responseWithData:[responseData copy] statusCode:201 headers:nil];
    }];
    NSURL *hostURL = [NSURL URLWithString:@"https://github.com/pavelosipov"];
    [_gateway pushRequest:[POSHTTPRequest new] toHost:hostURL options:nil];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

//- (void)testCancel {
//    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
//    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        NSLog(@"activating");
//        RACDisposable *disposable = [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
//            NSLog(@"sending");
//            [subscriber sendNext:@1];
//            [subscriber sendCompleted];
//        }];
//        return [RACDisposable disposableWithBlock:^{
//            NSLog(@"canceling");
//            [disposable dispose];
//        }];
//    }];
//    RACMulticastConnection *connection = [signal multicast:RACReplaySubject.subject];
//    RACDisposable *connectionDisposable = [connection connect];
//    RACSignal *gatewaySignal = connection.signal;
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [connection.signal subscribe:subscriber];
//        return connectionDisposable;
//    }];
//    RACSignal *endpoiintSignal = [gatewaySignal catchTo:[RACSignal empty]];
//    RACDisposable *d1 = [endpoiintSignal subscribeNext:^(id x) {
//        NSLog(@"1: next");
//    } error:^(NSError *error) {
//        NSLog(@"1: error");
//    } completed:^{
//        NSLog(@"1: completed");
//    }];
//    RACDisposable *d2 = [endpoiintSignal subscribeNext:^(id x) {
//        NSLog(@"2: next");
//    } error:^(NSError *error) {
//        NSLog(@"2: error");
//    } completed:^{
//        NSLog(@"2: completed");
//    }];
//    [d2 dispose];
//    [self waitForExpectationsWithTimeout:1 handler:nil];
//}

@end
