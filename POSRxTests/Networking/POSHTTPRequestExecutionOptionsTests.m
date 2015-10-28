//
//  POSHTTPRequestExecutionOptionsTests.m
//  POSRx
//
//  Created by Pavel Osipov on 28.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>
#import <XCTest/XCTest.h>

@interface POSHTTPRequestExecutionOptionsTests : XCTestCase

@end

@implementation POSHTTPRequestExecutionOptionsTests

- (void)testExecutionOptionsMerge1 {
    POSHTTPRequestExecutionOptions *sourceOptions =
        [[POSHTTPRequestExecutionOptions alloc]
         initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                              initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                     @"X-Header10": @"10"}
                              allowUntrustedSSLCertificates:@(YES)]
         simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                            initWithRate:1.0f
                            responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *targetOptions =
        [[POSHTTPRequestExecutionOptions alloc]
         initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                              initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                                     @"X-Header20": @"20"}
                              allowUntrustedSSLCertificates:@(NO)]
         simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                            initWithRate:0.5f
                            responses:@{[[POSHTTPResponse alloc] initWithStatusCode:500]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:targetOptions];
    XCTAssertTrue(mergedOptions != sourceOptions);
    XCTAssertTrue(mergedOptions != targetOptions);
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    XCTAssertTrue(mergedOptions.simulation.rate != 1.0);
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 500);
}

- (void)testExecutionOptionsMerge2 {
    POSHTTPRequestExecutionOptions *targetOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                                 @"X-Header20": @"20"}
                          allowUntrustedSSLCertificates:@(NO)]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:0.5f
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:500]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:nil
                                                     with:targetOptions];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 500);
}

- (void)testExecutionOptionsMerge3 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          allowUntrustedSSLCertificates:@(YES)]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:1.0f
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:nil];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(YES));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/1.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 200);
}

- (void)testExecutionOptionsMerge4 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:nil
                          allowUntrustedSSLCertificates:nil]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:1.0f
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *targetOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                                 @"X-Header20": @"20"}
                          allowUntrustedSSLCertificates:@(NO)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:targetOptions];
    XCTAssertTrue(mergedOptions != sourceOptions);
    XCTAssertTrue(mergedOptions != targetOptions);
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 200);
}

- (void)testExecutionOptionsMerge5 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          allowUntrustedSSLCertificates:@(YES)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *targetOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:nil
                          allowUntrustedSSLCertificates:nil]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:0.5f
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:500]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:targetOptions];
    XCTAssertTrue(mergedOptions != sourceOptions);
    XCTAssertTrue(mergedOptions != targetOptions);
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(YES));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/1.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertTrue(mergedOptions.simulation.rate != 1.0);
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 500);
}

- (void)testExecutionOptionsMerge6 {
    POSHTTPRequestExecutionOptions *mergedOptions =
    [POSHTTPRequestExecutionOptions
     merge:nil
     withHTTPOptions:[[POSHTTPRequestOptions alloc]
                      initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                             @"X-Header10": @"10"}
                      allowUntrustedSSLCertificates:@(YES)]];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(YES));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/1.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertNil(mergedOptions.simulation);
}

- (void)testExecutionOptionsMerge7 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          allowUntrustedSSLCertificates:@(YES)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *mergedOptions =
    [POSHTTPRequestExecutionOptions
     merge:sourceOptions
     withHTTPOptions:[[POSHTTPRequestOptions alloc]
                      initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                             @"X-Header20": @"20"}
                      allowUntrustedSSLCertificates:@(NO)]];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    XCTAssertNil(mergedOptions.simulation);
}

@end
