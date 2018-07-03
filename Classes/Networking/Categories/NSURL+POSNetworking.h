//
//  NSURL+POSNetworking.h
//  POSNetworking
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright © 2014 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (POSNetworking)

- (nullable NSURL *)pos_URLByAppendingEscapedPathComponent:(nullable NSString *)pathComponent;

- (nullable NSURL *)pos_URLByAppendingPathComponent:(nullable NSString *)pathComponent;

- (nullable NSURL *)pos_URLByAppendingQueryString:(nullable NSString *)queryString;

- (instancetype)pos_URLByAppendingPath:(nullable NSString *)path
                                 query:(nullable NSDictionary<NSString *, id<NSObject>> *)query;

@end

NS_ASSUME_NONNULL_END
