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

- (void)testExecutionOptionsMerge {
    POSHTTPRequestExecutionOptions *targetOptions =
        [[POSHTTPRequestExecutionOptions alloc]
         initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                              initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                     @"X-Header10": @"10"}
                              allowUntrustedSSLCertificates:@(YES)]
         simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                            initWithRate:1.0f
                            responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *sourceOptions =
        [[POSHTTPRequestExecutionOptions alloc]
         initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                              initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                                     @"X-Header20": @"20"}
                              allowUntrustedSSLCertificates:@(NO)]
         simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                            initWithRate:1.0f
                            responses:@{[[POSHTTPResponse alloc] initWithStatusCode:500]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [targetOptions merge:sourceOptions];
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

@end
