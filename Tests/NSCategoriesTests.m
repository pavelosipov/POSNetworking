//
//  NSURLCategoryTests.m
//  POSNetworking
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSNetworking/POSNetworking.h>
#import <XCTest/XCTest.h>

@interface NSCategoriesTests : XCTestCase
@end

@implementation NSCategoriesTests

#pragma mark - Path Tests

- (void)testPathConcatWithoutSlashes {
    NSURL *partialURL = [@"https://github.com" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"pavelosipov" query:nil];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" pos_URL]);
}

- (void)testPathConcatWithSlashAfterHost {
    NSURL *partialURL = [@"https://github.com/" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"pavelosipov" query:nil];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" pos_URL]);
}

- (void)testPathConcatWithSlashedPath {
    NSURL *partialURL = [@"https://github.com" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"/pavelosipov" query:nil];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" pos_URL]);
}

- (void)testPathConcatWithSlashesEverywhere {
    NSURL *partialURL = [@"https://github.com/" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"/pavelosipov" query:nil];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" pos_URL]);
}

#pragma mark - Query Tests

- (void)testQueryConcatWithHostWithoutSlash {
    NSURL *partialURL = [@"https://github.com" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:nil query:@{@"number": @0, @"string": @"s", @"boolean": @YES}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com?number=0&string=s&boolean=1" pos_URL]);
}

- (void)testQueryConcatWithHostWithSlash {
    NSURL *partialURL = [@"https://github.com/" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:nil query:@{@"number": @0, @"string": @"s", @"boolean": @NO}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/?number=0&string=s&boolean=0" pos_URL]);
}

#pragma mark - Path & Query Tests

- (void)testPathAndQueryConcatWithHostWithoutSlash {
    NSURL *partialURL = [@"https://github.com" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"pavelosipov"
                                                  query:@{@"number": @0, @"string": @"s", @"boolean": @YES}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov?number=0&string=s&boolean=1" pos_URL]);
}

- (void)testPathAndQueryConcatWithHostWithSlash {
    NSURL *partialURL = [@"https://github.com/" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"pavelosipov"
                                                  query:@{@"number": @0, @"string": @"s", @"boolean": @NO}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov?number=0&string=s&boolean=0" pos_URL]);
}

- (void)testPathWithSlashesAndQueryConcatWithHostWithoutSlash {
    NSURL *partialURL = [@"https://github.com" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"/api/v2/"
                                                  query:@{@"number": @0, @"string": @"s", @"boolean": @NO}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/api/v2/?number=0&string=s&boolean=0" pos_URL]);
}

- (void)testPathWithSlashesAndQueryConcatWithHostWithSlash {
    NSURL *partialURL = [@"https://github.com/" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"/pavelosipov/"
                                                  query:@{@"number": @0, @"string": @"s", @"boolean": @NO}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov/?number=0&string=s&boolean=0" pos_URL]);
}

#pragma mark - NSString

- (void)testStringTrimming {
    XCTAssertEqualObjects(@"asdfg", [@"123asdfg123" pos_trimSymbol:@"123"]);
    XCTAssertEqualObjects(@"asdfg", [@"123asdfg" pos_trimSymbol:@"123"]);
    XCTAssertEqualObjects(@"asdfg", [@"asdfg123" pos_trimSymbol:@"123"]);
    XCTAssertEqualObjects(@"asdfg", [@"/asdfg/" pos_trimSymbol:@"/"]);
    XCTAssertEqualObjects(@"asdfg", [@"asdfg/" pos_trimSymbol:@"/"]);
    XCTAssertEqualObjects(@"asdfg", [@"/asdfg" pos_trimSymbol:@"/"]);
    XCTAssertEqualObjects(@"asdfg", [@"asdfg" pos_trimSymbol:@"123"]);
    XCTAssertEqualObjects(@"asdfg", [@"asdfg" pos_trimSymbol:@"/"]);
}

/*
- (void)testQueryMerge {
    NSURL *partialURL = [@"https://github.com/" pos_URL];
    NSURL *fullURL = [partialURL pos_URLByAppendingPath:@"/pavelosipov/"
                                                  query:@{@"number": @0, @"string": @"s", @"boolean": @NO}
                                       withExtraQueryParams:@{@"string": @"f", @"appended": @"a"}];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov/?number=0&string=f&boolean=0&appended=a" posrx_URL]);
}
*/

@end
