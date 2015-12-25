//
//  POSHTTPRequestMethod.h
//  POSRx
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

/// URL components, which will be appended to host URL.
@interface POSHTTPRequestMethod : NSObject <NSCoding>

/// Path, which will be appended after '/' to host URL.
@property (nonatomic, readonly) NSString *path;

/// Query parameters, which will be appended after path using '?' or '&' delimeter.
@property (nonatomic, readonly) NSDictionary *query;

/// Creates method which contains only path.
+ (instancetype)path:(NSString *)path;

/// Creates method which contains path and query.
+ (instancetype)path:(NSString *)path
               query:(NSDictionary *)query;

/// Creates method which contains only query.
+ (instancetype)query:(NSDictionary *)query;

/// Creates URL, where method components are appended to specified URL.
- (NSURL *)appendTo:(NSURL *)URL;

/// Creates URL, where method components are appended to specified URL with additional query parameter.
- (NSURL *)appendTo:(NSURL *)URL
          withQuery:(NSDictionary *)query;

@end
