//
//  POSHTTPMethod.m
//  POSNetworking
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestMethod.h"
#import "NSDictionary+POSNetworking.h"
#import "NSURL+POSNetworking.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPRequestMethod()
@property (nonatomic) NSString *path;
@property (nonatomic) NSDictionary *query;
@end

@implementation POSHTTPRequestMethod

+ (instancetype)path:(nullable NSString *)path {
    return [self path:path query:nil];
}

+ (instancetype)query:(nullable NSDictionary *)query {
    return [self path:nil query:query];
}

+ (instancetype)path:(nullable NSString *)path query:(nullable NSDictionary *)query {
    POSHTTPRequestMethod *method = [[POSHTTPRequestMethod alloc] init];
    if ([path hasPrefix:@"/"]) {
        method.path = [path substringFromIndex:1];
    } else {
        method.path =  [path copy];
    }
    method.query = [query copy];
    return method;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@{path='%@', query='%@'}",
            super.description, _path, [_query pos_URLQueryEncoded:NO]];
}

@end

#pragma mark -

@implementation NSURL (POSHTTPRequestMethod)

- (NSURL *)pos_URLByAppendingMethod:(nullable POSHTTPRequestMethod *)method {
    return [self pos_URLByAppendingMethod:method withExtraQueryParams:nil];
}

- (NSURL *)pos_URLByAppendingMethod:(nullable POSHTTPRequestMethod *)method
                  withExtraURLQuery:(nullable NSDictionary<NSString *, id<NSObject>> *)query {
    NSURL *fullURL = self;
    if (method.path) {
        POS_CHECK(!fullURL.query);
        fullURL = [fullURL pos_URLByAppendingEscapedPathComponent:
                   [method.path stringByAddingPercentEncodingWithAllowedCharacters:
                    NSCharacterSet.URLPathAllowedCharacterSet]];
    }
    NSDictionary *fullQuery = [NSDictionary pos_merge:method.query with:query];
    if (fullQuery) {
        POS_CHECK(!fullURL.fragment);
        fullURL = [fullURL pos_URLByAppendingQueryString:[fullQuery pos_URLQuery]];
    }
    return fullURL;
}

@end

NS_ASSUME_NONNULL_END
