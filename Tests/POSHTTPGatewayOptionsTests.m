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

- (void)testMergeResponseOptions {
    POSHTTPGatewayOptions *source, *target, *merged;
    
    source = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:nil] build];
    target = [[[[POSHTTPGatewayOptionsBuilder alloc] init] withResponseOptions:nil] build];
    merged = [POSHTTPGatewayOptions merge:source with:target];
    XCTAssertNil(merged.responseOptions);
}

@end

NS_ASSUME_NONNULL_END
