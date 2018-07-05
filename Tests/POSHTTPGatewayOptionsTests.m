//
//  POSHTTPRequestTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 28.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSNetworking/POSNetworking.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPGatewayOptionsTests : XCTestCase

@end

@implementation POSHTTPGatewayOptionsTests

- (void)testResponseOptionsProbability {
    POSHTTPResponseOptions *options = [[POSHTTPResponseOptions alloc] initWithRate:25 responseSimulator:
                                       ^POSHTTPResponse *(id<POSHTTPRequest> request,
                                                          NSURL *hostURL,
                                                          POSHTTPRequestOptions * _Nullable options) {
                                           return [[POSHTTPResponse alloc] initWithStatusCode:10];
                                       }];
    NSUInteger responseCount = 0;
    for (NSUInteger i = 0; i < 10000; ++i) {
        POSHTTPResponse *response = [options
                                     probeSimulationForRequest:[POSHTTPGET build]
                                     hostURL:[@"https://github.com" pos_URL]
                                     options:nil];
        if (response) {
            ++responseCount;
        }
    }
    XCTAssertTrue(responseCount > 2300 && responseCount < 2700);
}

- (void)testMergeResponseOptions {
    POSHTTPGatewayOptions *source, *target, *merged;
    POSHTTPResponseOptions *optionsA = [[POSHTTPResponseOptions alloc] initWithRate:100 responseSimulator:
                                        ^POSHTTPResponse *(id<POSHTTPRequest> request,
                                                           NSURL *hostURL,
                                                           POSHTTPRequestOptions * _Nullable options) {
                                            return [[POSHTTPResponse alloc] initWithStatusCode:10];
                                        }];
    POSHTTPResponseOptions *optionsB = [[POSHTTPResponseOptions alloc] initWithRate:100 responseSimulator:
                                        ^POSHTTPResponse *(id<POSHTTPRequest> request,
                                                           NSURL *hostURL,
                                                           POSHTTPRequestOptions * _Nullable options) {
                                            return [[POSHTTPResponse alloc] initWithStatusCode:20];
                                        }];
    POSHTTPRequest *request = [POSHTTPGET build];
    NSURL *URL = [@"https://github.com" pos_URL];
    
    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:nil] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:nil] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertNil(merged.responseOptions);

    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:optionsA] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:nil] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertTrue([merged.responseOptions
                   probeSimulationForRequest:request hostURL:URL options:nil].metadata.statusCode == 10);

    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:nil] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:optionsB] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertTrue([merged.responseOptions
                   probeSimulationForRequest:request hostURL:URL options:nil].metadata.statusCode == 20);

    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:optionsA] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:optionsB] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertTrue([merged.responseOptions
                   probeSimulationForRequest:request hostURL:URL options:nil].metadata.statusCode == 20);
}

- (void)testMergeRequestOptions {
    POSHTTPGatewayOptions *source, *target, *merged;
    
    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:
               [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @1}] build]] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:
               [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"b": @2}] build]] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertEqualObjects(merged.requestOptions.URLQuery[@"a"], @1);
    XCTAssertEqualObjects(merged.requestOptions.URLQuery[@"b"], @2);

    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:nil] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:
               [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"b": @2}] build]] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertEqualObjects(merged.requestOptions.URLQuery[@"b"], @2);

    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:
               [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @1}] build]] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:nil] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertEqualObjects(merged.requestOptions.URLQuery[@"a"], @1);

    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:
               [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @1}] build]] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withRequestOptions:
               [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @2}] build]] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertEqualObjects(merged.requestOptions.URLQuery[@"a"], @2);
}

@end

NS_ASSUME_NONNULL_END
