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



/*
- (void)testExecutionOptionsMerge1 {
    POSHTTPRequestExecutionOptions *sourceOptions =
        [[POSHTTPRequestExecutionOptions alloc]
         initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                              initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                     @"X-Header10": @"10"}
                              queryParameters:nil
                              allowUntrustedSSLCertificates:@(YES)
                              responseTimeout:@(30.0)]
         simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                            initWithRate:100
                            responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *targetOptions =
        [[POSHTTPRequestExecutionOptions alloc]
         initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                              initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                                     @"X-Header20": @"20"}
                              queryParameters:nil
                              allowUntrustedSSLCertificates:@(NO)
                              responseTimeout:@(45.0)]
         simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                            initWithRate:50
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
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 45.0) <= FLT_EPSILON);
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
                          queryParameters:nil
                          allowUntrustedSSLCertificates:@(NO)
                          responseTimeout:@(50.0)]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:50
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:500]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:nil
                                                     with:targetOptions];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 50.0) <= FLT_EPSILON);
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 500);
}

- (void)testExecutionOptionsMerge3 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          queryParameters:nil
                          allowUntrustedSSLCertificates:@(YES)
                          responseTimeout:@(60.0)]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:100
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:nil];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(YES));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/1.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 60.0) <= FLT_EPSILON);
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 200);
}

- (void)testExecutionOptionsMerge4 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:nil
                          queryParameters:nil
                          allowUntrustedSSLCertificates:nil
                          responseTimeout:nil]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:100
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:200]: @(1)}]];
    POSHTTPRequestExecutionOptions *targetOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                                 @"X-Header20": @"20"}
                          queryParameters:nil
                          allowUntrustedSSLCertificates:@(NO)
                          responseTimeout:@(70.0)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:targetOptions];
    XCTAssertTrue(mergedOptions != sourceOptions);
    XCTAssertTrue(mergedOptions != targetOptions);
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 70.0) <= FLT_EPSILON);
    POSHTTPResponse *mergedResponse = mergedOptions.simulation.responses.allKeys.firstObject;
    XCTAssertTrue(mergedResponse.metadata.statusCode == 200);
}

- (void)testExecutionOptionsMerge5 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          queryParameters:nil
                          allowUntrustedSSLCertificates:@(YES)
                          responseTimeout:@(80.0)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *targetOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:nil
                          queryParameters:nil
                          allowUntrustedSSLCertificates:nil
                          responseTimeout:nil]
     simulationOptions:[[POSHTTPRequestSimulationOptions alloc]
                        initWithRate:50
                        responses:@{[[POSHTTPResponse alloc] initWithStatusCode:500]: @(1)}]];
    POSHTTPRequestExecutionOptions *mergedOptions = [POSHTTPRequestExecutionOptions
                                                     merge:sourceOptions
                                                     with:targetOptions];
    XCTAssertTrue(mergedOptions != sourceOptions);
    XCTAssertTrue(mergedOptions != targetOptions);
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(YES));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/1.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 80.0) <= FLT_EPSILON);
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
                      queryParameters:nil
                      allowUntrustedSSLCertificates:@(YES)
                      responseTimeout:@(90.0)]];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(YES));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/1.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 90.0) <= FLT_EPSILON);
    XCTAssertNil(mergedOptions.simulation);
}

- (void)testExecutionOptionsMerge7 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          queryParameters:nil
                          allowUntrustedSSLCertificates:@(YES)
                          responseTimeout:@(15.0)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *mergedOptions =
    [POSHTTPRequestExecutionOptions
     merge:sourceOptions
     withHTTPOptions:[[POSHTTPRequestOptions alloc]
                      initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                             @"X-Header20": @"20"}
                      queryParameters:nil
                      allowUntrustedSSLCertificates:@(NO)
                      responseTimeout:@(20.0)]];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 20.0) <= FLT_EPSILON);
    XCTAssertNil(mergedOptions.simulation);
}

- (void)testExecutionOptionsMerge8 {
    POSHTTPRequestExecutionOptions *sourceOptions =
    [[POSHTTPRequestExecutionOptions alloc]
     initWithHTTPOptions:[[POSHTTPRequestOptions alloc]
                          initWithHeaderFields:@{@"User-Agent": @"MyApp/1.0.0",
                                                 @"X-Header10": @"10"}
                          queryParameters:@{@"token": @"134",
                                            @"from": @"123"}
                          allowUntrustedSSLCertificates:@(YES)
                          responseTimeout:@(35.0)]
     simulationOptions:nil];
    POSHTTPRequestExecutionOptions *mergedOptions =
    [POSHTTPRequestExecutionOptions
     merge:sourceOptions
     withHTTPOptions:[[POSHTTPRequestOptions alloc]
                      initWithHeaderFields:@{@"User-Agent": @"MyApp/2.0.0",
                                             @"X-Header20": @"20"}
                      queryParameters:@{@"token": @"432"}
                      allowUntrustedSSLCertificates:@(NO)
                      responseTimeout:@(40.0)]];
    XCTAssertEqualObjects(mergedOptions.HTTP.allowUntrustedSSLCertificates, @(NO));
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"User-Agent"], @"MyApp/2.0.0");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header10"], @"10");
    XCTAssertEqualObjects(mergedOptions.HTTP.headerFields[@"X-Header20"], @"20");
    XCTAssertEqualObjects(mergedOptions.HTTP.queryParameters[@"token"], @"432");
    XCTAssertEqualObjects(mergedOptions.HTTP.queryParameters[@"from"], @"123");
    XCTAssertTrue(fabs(mergedOptions.HTTP.responseTimeout.doubleValue - 40.0) <= FLT_EPSILON);
    XCTAssertNil(mergedOptions.simulation);
}
*/
@end
