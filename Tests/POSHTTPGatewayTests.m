//
//  POSHTTPGatewayTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 09.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSNetworking/POSNetworking.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <XCTest/XCTest.h>

@interface NSURLComponents (POSHTTPGatewayTests)
- (NSDictionary<NSString *, NSString *> *)pos_queryItems;
@end

#pragma mark -

@interface POSHTTPGatewayTests : XCTestCase
@property (nonatomic) POSHTTPGateway *gateway;
@end

@implementation POSHTTPGatewayTests

- (void)setUp {
    [super setUp];
    self.gateway = [[POSHTTPGateway alloc]
                    initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                    backgroundSessionIdentifier:@"com.github.pavelosipov.HTTPGatewayTests"
                    options:nil];
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
    POSHTTPGatewayOptions *options = [[POSHTTPGatewayOptions alloc]
        initWithRequestOptions:[[[[POSHTTPRequestOptionsBuilder alloc] init]
            withBody:responseData]
            build]
        responseOptions:[[POSHTTPResponseOptions alloc]
            initWithRate:100
            responseSimulator:^POSHTTPResponse * (id<POSHTTPRequest> request,
                                                  NSURL *URL,
                                                  POSHTTPRequestOptions * _Nullable options) {
                XCTAssertEqualObjects(URL, hostURL);
                return [[POSHTTPResponse alloc]
                    initWithData:options.body
                    metadata:[[NSHTTPURLResponse alloc] initWithURL:URL statusCode:200 HTTPVersion:@"1.1" headerFields:nil]];
            }]];
    [[[_gateway
        taskForRequest:[POSHTTPGET build] toHost:hostURL hostOptions:nil extraOptions:options]
        execute]
        subscribeNext:^(POSHTTPResponse *response) {
            XCTAssertTrue(response.metadata.statusCode == 200);
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
    [[[_gateway
        taskForRequest:[POSHTTPGET build] toHost:hostURL hostOptions:nil extraOptions:nil]
        execute]
        subscribeNext:^(POSHTTPResponse *response) {
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
    [[[_gateway
        taskForRequest:[POSHTTPGET build] toHost:[hostURL copy] hostOptions:nil extraOptions:nil]
        execute]
        subscribeError:^(NSError *error) {
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
    POSTask *task = [_gateway taskForRequest:[POSHTTPGET build] toHost:hostURL hostOptions:nil extraOptions:nil];
    [task.values subscribeNext:^(POSHTTPResponse *response) {
        XCTAssertTrue(response.metadata.statusCode == 201);
        [expectation fulfill];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHTTPGatewayOptionsResolving {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:NO];
        XCTAssertEqualObjects(components.path, @"/gateway/host/request/extra");
        NSDictionary<NSString *, NSString *> *queryItems = [components pos_queryItems];
        XCTAssertEqualObjects(queryItems[@"a"], @"1");
        XCTAssertEqualObjects(queryItems[@"b"], @"2");
        XCTAssertEqualObjects(queryItems[@"c"], @"3");
        XCTAssertEqualObjects(queryItems[@"d"], @"4");
        XCTAssertEqualObjects(queryItems[@"x"], @"2", @"overrided by host");
        XCTAssertEqualObjects(queryItems[@"y"], @"3", @"overrided by request");
        XCTAssertEqualObjects(queryItems[@"z"], @"4", @"overrided by extra");
        NSDictionary<NSString *, NSString *> *headerFields = request.allHTTPHeaderFields;
        XCTAssertEqualObjects(headerFields[@"a"], @"1");
        XCTAssertEqualObjects(headerFields[@"b"], @"2");
        XCTAssertEqualObjects(headerFields[@"c"], @"3");
        XCTAssertEqualObjects(headerFields[@"d"], @"4");
        XCTAssertEqualObjects(headerFields[@"x"], @"2", @"overrided by host");
        XCTAssertEqualObjects(headerFields[@"y"], @"3", @"overrided by request");
        XCTAssertEqualObjects(headerFields[@"z"], @"4", @"overrided by extra");
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    POSHTTPGatewayOptions *gatewayOptions = [[[[POSHTTPGatewayOptionsBuilder alloc] init]
        withRequestOptions:[[[[[[POSHTTPRequestOptionsBuilder alloc] init]
            withPath:@"/gateway"]
            withQuery:@{@"a": @1, @"z": @1, @"y": @1, @"x": @1}]
            withHeaderFields:@{@"a": @"1"}]
            build]]
        build];
    POSHTTPGatewayOptions *hostOptions = [[[[POSHTTPGatewayOptionsBuilder alloc] init]
        withRequestOptions:[[[[[[POSHTTPRequestOptionsBuilder alloc] init]
            withPath:@"/host"]
            withQuery:@{@"b": @2, @"z": @2, @"y": @2, @"x": @2}]
            withHeaderFields:@{@"b": @"2", @"z": @"2", @"y": @"2", @"x": @"2"}]
            build]]
        build];
    POSHTTPRequestOptions *requestOptions = [[[[[[POSHTTPRequestOptionsBuilder alloc] init]
        withPath:@"/request"]
        withQuery:@{@"c": @3, @"z": @3, @"y": @3}]
        withHeaderFields:@{@"c": @"3", @"z": @"3", @"y": @"3"}]
        build];
    POSHTTPGatewayOptions *extraOptions = [[[[POSHTTPGatewayOptionsBuilder alloc] init]
        withRequestOptions:[[[[[[POSHTTPRequestOptionsBuilder alloc] init]
            withPath:@"/extra"]
            withQuery:@{@"d": @4, @"z": @4}]
            withHeaderFields:@{@"d": @"4", @"z": @"4"}]
            build]]
        build];
    self.gateway = [[POSHTTPGateway alloc] initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                                 backgroundSessionIdentifier:nil
                                                     options:gatewayOptions];
    id<POSHost> host = [[POSStaticHost alloc] initWithURL:[@"https://github.com" pos_URL]
                                                  gateway:_gateway
                                                  options:hostOptions];
    id<POSTask> requestTask = [POSTask createTask:^RACSignal *(id _) {
        return [host pushRequest:[[[[POSHTTPGET alloc] init] withOptions:requestOptions] build]
                         options:extraOptions];
    }];
    [[requestTask execute] subscribeCompleted:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end

#pragma mark -

@implementation NSURLComponents (POSHTTPGatewayTests)

- (NSDictionary<NSString *, NSString *> *)pos_queryItems {
    NSMutableDictionary<NSString *, NSString *> *items = [[NSMutableDictionary alloc] init];
    [self.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        items[item.name] = item.value;
    }];
    return items;
}

@end
