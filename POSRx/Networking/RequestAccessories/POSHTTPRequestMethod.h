//
//  POSHTTPRequestMethod.h
//  POSRx
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// URL components, which will be appended to host URL.
@interface POSHTTPRequestMethod : NSObject <NSCoding>

/// Path, which will be appended after '/' to host URL.
@property (nonatomic, readonly, nullable) NSString *path;

/// Query parameters, which will be appended after path using '?' or '&' delimeter.
@property (nonatomic, readonly, nullable) NSDictionary *query;

/// Creates method which contains only path.
+ (instancetype)path:(nullable NSString *)path;

/// Creates method which contains path and query.
+ (instancetype)path:(nullable NSString *)path
               query:(nullable NSDictionary *)query;

/// Creates method which contains only query.
+ (instancetype)query:(nullable NSDictionary *)query;

@end

NS_ASSUME_NONNULL_END
