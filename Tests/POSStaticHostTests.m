//
//  POSStaticHostTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 05.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSNetworking/POSNetworking.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@interface POSStaticHostTests : XCTestCase
@property (nonatomic) id<POSHTTPGateway> gateway;
@property (nonatomic) id<POSHost> host;
@property (nonatomic, copy) RACSignal *(^errorHandlingBlock)(NSError *error);
@end

@implementation POSStaticHostTests

- (void)setUp {
    [super setUp];
    [POSAllocationTracker resetAllCounters];
}

- (void)hostSetUp {
    self.gateway = [[POSHTTPGateway alloc]
                    initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                    backgroundSessionIdentifier:nil
                    options:nil];
    self.host = [[POSStaticHost alloc] initWithURL:[@"https://cloud.mail.ru" pos_URL]
                                           gateway:_gateway
                                           options:nil];
}

- (void)hostTearDownWithExpectation:(XCTestExpectation *)expectation {
    [[_gateway invalidateForced:YES] subscribeCompleted:^{
        self.gateway = nil;
        self.host = nil;
        [[RACScheduler mainThreadScheduler] afterDelay:0.01 schedule:^{
            [expectation fulfill];
        }];
    }];
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSHost.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:POSHTTPGateway.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

#pragma mark - Default response handling tests

- (void)testHostShouldEmitOriginalResponseWithoutCustomResponseHandlers {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    POSHTTPGatewayOptions *options = [self optionsWith:[[POSHTTPResponse alloc] initWithData:[data copy]]];
    POSHTTPRequest *request = [POSHTTPGET request];
    [[_host pushRequest:request options:options] subscribeNext:^(POSHTTPResponse *response) {
        XCTAssertEqualObjects(response.data, data);
    } completed:^{
        [self hostTearDownWithExpectation:expectation];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostDefaultResponseHandlerShouldEmitServerErrorForNon2XXResponses {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    POSHTTPGatewayOptions *options = [self optionsWith:[[POSHTTPResponse alloc] initWithStatusCode:404]];
    POSHTTPRequest *request = [POSHTTPGET request];
    [[_host pushRequest:request options:options] subscribeNext:^(id response) {
        XCTAssert(NO);
    } error:^(NSError *error) {
        XCTAssertEqualObjects(error.domain, kPOSErrorDomain);
        XCTAssert([error.pos_category isEqualToString:kPOSServerErrorCategory]);
        XCTAssert(error.pos_HTTPStatusCode.unsignedIntegerValue == 404);
        [self hostTearDownWithExpectation:expectation];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Custom response handling tests

- (void)testHostShouldNotEmitValuesWhenCustomResponseHandlerReturnsNil {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSHTTPURLResponse *metadata = [[NSHTTPURLResponse alloc]
                                   initWithURL:self.host.URL
                                   statusCode:202
                                   HTTPVersion:@"1.1"
                                   headerFields:nil];
    POSHTTPGatewayOptions *options = [self optionsWith:[[POSHTTPResponse alloc] initWithData:[data copy]
                                                                                    metadata:metadata]];
    @weakify(self);
    POSHTTPRequest *request = [[[[POSHTTPGET alloc] init]
        withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
            @strongify(self);
            XCTAssertEqualObjects(response.data, data);
            XCTAssertEqualObjects(response.metadata.URL, self.host.URL);
            XCTAssert(response.metadata.statusCode == 202);
            return nil;
        }] build];
    [[_host pushRequest:request options:options] subscribeNext:^(id response) {
        XCTAssert(NO);
    } completed:^{
        [self hostTearDownWithExpectation:expectation];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldEmitCustomResponseHandlerResult {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    POSHTTPGatewayOptions *options = [self optionsWith:[[POSHTTPResponse alloc] initWithData:[data copy]]];
    POSHTTPRequest *request = [[[[POSHTTPGET alloc] init]
        withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
            XCTAssertEqualObjects(response.data, data);
            return @"123";
        }] build];
    [[_host pushRequest:request options:options] subscribeNext:^(NSString *customResponse) {
        XCTAssertEqualObjects(customResponse, @"123");
    } completed:^{
        [self hostTearDownWithExpectation:expectation];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldEmitErrorFromCustomResponseHandler {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    [[_host
      pushRequest:[[[[POSHTTPGET alloc] init]
      withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
          *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
          return nil;
      }] build]
      options:[self optionsWith:[[POSHTTPResponse alloc] initWithStatusCode:204]]]
      subscribeNext:^(id response) {
          XCTAssert(NO);
      }
      error:^(NSError *error) {
          XCTAssertEqualObjects(error.domain, @"test");
          [self hostTearDownWithExpectation:expectation];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldEmitErrorWhenCustomResponseHandlerThrowsExceeption {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    [[_host
      pushRequest:[[[[POSHTTPGET alloc] init]
      withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
          POS_CHECK(NO);
          return nil;
      }] build]
      options:[self optionsWith:[[POSHTTPResponse alloc] initWithStatusCode:204]]]
      subscribeNext:^(id response) {
          XCTAssert(NO);
      }
      error:^(NSError *error) {
          [self hostTearDownWithExpectation:expectation];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Custom response data handling tests

- (void)testHostShouldEmitHTTPResponseWhenCustomResponseDataHandlerReturnsNil {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    [[_host
      pushRequest:[[[[POSHTTPGET alloc] init]
      withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
          return nil;
      }] build]
      options:[self optionsWith:[[POSHTTPResponse alloc] initWithData:NSData.new]]]
      subscribeNext:^(id response) {
          XCTAssert(NO);
      }
      completed:^{
          [self hostTearDownWithExpectation:expectation];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldEmitCustomResponseDataHandlerResult {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    const uint8_t bytes[] = { 0xb7, 0xe2, 0x02 };
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [[_host
      pushRequest:[[[[POSHTTPGET alloc] init]
      withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
          XCTAssertEqualObjects(response.data, data);
          return @"123";
      }] build]
      options:[self optionsWith:[[POSHTTPResponse alloc] initWithData:[data copy]]]]
      subscribeNext:^(NSString *customResponse) {
          XCTAssertEqualObjects(customResponse, @"123");
      }
      completed:^{
          [self hostTearDownWithExpectation:expectation];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldEmitErrorFromCustomResponseDataHandler {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    [[_host
      pushRequest:[[[[POSHTTPGET alloc] init]
      withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
          *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
          return nil;
      }] build]
      options:[self optionsWith:[[POSHTTPResponse alloc] initWithData:NSData.new]]]
      subscribeNext:^(id response) {
          XCTAssert(NO);
      }
      error:^(NSError *error) {
          XCTAssertEqualObjects(error.domain, @"test");
          [self hostTearDownWithExpectation:expectation];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldEmitErrorWhenCustomResponseDataHandlerThrowsException {
    [self hostSetUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
    [[_host
      pushRequest:[[[[POSHTTPGET alloc] init]
      withResponseHandler:^id _Nullable(POSHTTPResponseHandler _, POSHTTPResponse *response, NSError **error) {
          POS_CHECK(NO);
          return nil;
      }] build]
      options:[self optionsWith:[[POSHTTPResponse alloc] initWithStatusCode:204]]]
      subscribeNext:^(id response) {
          XCTAssert(NO);
      }
      error:^(NSError *error) {
          [self hostTearDownWithExpectation:expectation];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Helpers 

- (POSHTTPGatewayOptions *)optionsWith:(POSHTTPResponse *)response {
    return [[[[POSHTTPGatewayOptionsBuilder alloc] init]
        withResponseOptions:[[POSHTTPResponseOptions alloc]
            initWithRate:100
            responseSimulator:^POSHTTPResponse *(id<POSHTTPRequest> _, NSURL *URL, POSHTTPRequestOptions *options) {
                return response;
            }]]
        build];
}

@end
