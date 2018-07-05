//
//  POSHTTPRequestTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 28.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSNetworking/POSNetworking.h>
#import <XCTest/XCTest.h>

@interface POSHTTPRequestTests : XCTestCase

@end

@implementation POSHTTPRequestTests

- (void)testMergeRequestOptionsAllowUntrustedSSLCertificates {
    POSHTTPRequestOptions *source, *target, *merged;
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@YES] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@NO] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.allowUntrustedSSLCertificates, @NO);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@NO] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@YES] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.allowUntrustedSSLCertificates, @YES);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertNil(merged.allowUntrustedSSLCertificates);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@YES] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.allowUntrustedSSLCertificates, @YES);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@NO] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.allowUntrustedSSLCertificates, @NO);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@YES] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.allowUntrustedSSLCertificates, @YES);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:@NO] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withAllowedUntrustedSSLCertificates:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.allowUntrustedSSLCertificates, @NO);
}

- (void)testMergeRequestOptionsResponseTimeout {
    POSHTTPRequestOptions *source, *target, *merged;
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:@10] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:@20] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.responseTimeout, @20);
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertNil(merged.responseTimeout);
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:@10] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.responseTimeout, @10);
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:@10] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withResponseTimeout:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.responseTimeout, @10);    
}

- (void)testMergeRequestOptionsURLPath {
    POSHTTPRequestOptions *source, *target, *merged;
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"pavelosipov"] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"posnetworking"] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLPath, @"pavelosipov/posnetworking");

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"/pavelosipov"] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"/posnetworking"] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLPath, @"pavelosipov/posnetworking");

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"pavelosipov/"] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"posnetworking/"] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLPath, @"pavelosipov/posnetworking");

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"/pavelosipov/"] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"/posnetworking/"] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLPath, @"pavelosipov/posnetworking");
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"posnetworking"] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLPath, @"posnetworking");
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:@"pavelosipov"] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withPath:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLPath, @"pavelosipov");
}

- (void)testMergeRequestOptionsURLQuery {
    POSHTTPRequestOptions *source, *target, *merged;
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @1}] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"b": @2}] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLQuery[@"a"], @1);
    XCTAssertEqualObjects(merged.URLQuery[@"b"], @2);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"b": @2}] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLQuery[@"b"], @2);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @1}] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLQuery[@"a"], @1);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @1}] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withQuery:@{@"a": @2}] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.URLQuery[@"a"], @2);
}

- (void)testMergeRequestOptionsHeaderFields {
    POSHTTPRequestOptions *source, *target, *merged;
    
    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:@{@"a": @"1"}] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:@{@"b": @"2"}] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.headerFields[@"a"], @"1");
    XCTAssertEqualObjects(merged.headerFields[@"b"], @"2");

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:@{@"b": @"2"}] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.headerFields[@"b"], @"2");

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:@{@"a": @"1"}] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.headerFields[@"a"], @"1");

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:@{@"a": @"1"}] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withHeaderFields:@{@"a": @"2"}] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.headerFields[@"a"], @"2");
}

- (void)testMergeRequestOptionsBody {
    POSHTTPRequestOptions *source, *target, *merged;

    const uint8_t bytesAA[] = { 0xaa };
    NSData *dataAA = [NSData dataWithBytes:bytesAA length:sizeof(bytesAA)];
    const uint8_t bytesBB[] = { 0xbb };
    NSData *dataBB = [NSData dataWithBytes:bytesBB length:sizeof(bytesBB)];

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withBody:dataAA] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withBody:dataBB] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.body, dataBB);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withBody:nil] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withBody:dataBB] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.body, dataBB);

    source = [[[[POSHTTPRequestOptionsBuilder alloc] init] withBody:dataAA] build];
    target = [[[[POSHTTPRequestOptionsBuilder alloc] init] withBody:nil] build];
    merged = [POSHTTPRequestOptions merge:source with:target];
    XCTAssertEqualObjects(merged.body, dataAA);
}

@end
