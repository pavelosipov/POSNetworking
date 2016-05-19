//
//  NSURL+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright (c) 2014 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POSHTTPRequestMethod;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (POSRx)

- (nullable NSURL *)posrx_URLByAppendingEscapedPathComponent:(nullable NSString *)pathComponent;
- (nullable NSURL *)posrx_URLByAppendingPathComponent:(nullable NSString *)pathComponent;
- (nullable NSURL *)posrx_URLByAppendingQueryString:(nullable NSString *)queryString;

- (NSURL *)posrx_URLByAppendingMethod:(nullable POSHTTPRequestMethod *)method;
- (NSURL *)posrx_URLByAppendingMethod:(nullable POSHTTPRequestMethod *)method
                 withExtraQueryParams:(nullable NSDictionary *)query;

@end

NS_ASSUME_NONNULL_END
