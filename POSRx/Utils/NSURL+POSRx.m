//
//  NSURL+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright (c) 2014 Pavel Osipov. All rights reserved.
//

#import "NSURL+POSRx.h"
#import "POSHTTPRequestMethod.h"
#import "NSDictionary+POSRx.h"
#import "NSString+POSRx.h"
#import "NSException+POSRx.h"

@implementation NSURL (POSRx)

- (NSURL *)posrx_URLByAppendingEscapedPathComponent:(NSString *)pathComponent {
    if (!pathComponent) {
        return self;
    }
    NSString *absoluteString = [self absoluteString];
    if (![absoluteString hasSuffix:@"/"]) {
        absoluteString = [absoluteString stringByAppendingString:@"/"];
    }
    absoluteString = [absoluteString stringByAppendingString:pathComponent];
    return [NSURL URLWithString:absoluteString];
}

- (nullable NSURL *)posrx_URLByAppendingPathComponent:(nullable NSString *)pathComponent {
    return [self posrx_URLByAppendingEscapedPathComponent:[pathComponent posrx_percentEscaped]];
}

- (NSURL *)posrx_URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    return [NSURL URLWithString:URLString];
}

- (NSURL *)posrx_URLByAppendingMethod:(nullable POSHTTPRequestMethod *)method {
    return [self posrx_URLByAppendingMethod:method withExtraQueryParams:nil];
}

- (NSURL *)posrx_URLByAppendingMethod:(POSHTTPRequestMethod *)method withExtraQueryParams:(NSDictionary *)query {
    NSURL *fullURL = self;
    if (method.path) {
        POSRX_CHECK(!fullURL.query);
        fullURL = [fullURL posrx_URLByAppendingEscapedPathComponent:method.path];
    }
    NSDictionary *fullQuery = [NSDictionary posrx_merge:method.query with:query];
    if (fullQuery) {
        POSRX_CHECK(!fullURL.fragment);
        fullURL = [fullURL posrx_URLByAppendingQueryString:[fullQuery posrx_URLQuery]];
    }
    return fullURL;
}


@end
