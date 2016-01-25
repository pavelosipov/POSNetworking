//
//  POSHTTPDownloadRequest.h
//  POSRx
//
//  Created by Pavel Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPDownloadRequest <POSHTTPRequest>

/// Handler of the downloaded file at specified path.
@property (nonatomic, readonly, nullable, copy) void (^fileHandler)(NSURL *location);

@end

#pragma mark -

/// Request to make foreground downloads using GET HTTP method.
@interface POSHTTPDownloadRequest : POSHTTPRequest <POSHTTPDownloadRequest>

/// The designated initializer for foreground download.
- (instancetype)initWithMethod:(nullable POSHTTPRequestMethod *)method
                   destination:(nullable void (^)(NSURL *))destination
                      progress:(nullable void (^)(POSHTTPRequestProgress *progress))progress
                  headerFields:(nullable NSDictionary *)headerFields;

/// Copying initializer.
- (instancetype)initWithRequest:(id<POSHTTPDownloadRequest>)request;

/// Hiding deadly initializers.
POSRX_HTTPREQUEST_TYPED_INIT_UNAVAILABLE;

@end

#pragma mark -

/// Mutable version of POSHTTPDownload request.
@interface POSMutableHTTPDownloadRequest : POSMutableHTTPRequest <POSHTTPDownloadRequest>

/// Handler of the downloaded file at specified path.
@property (nonatomic, copy) void (^fileHandler)(NSURL *location);

/// Creates HTTP GET request.
- (instancetype)init;

/// Copying initializer.
- (instancetype)initWithRequest:(id<POSHTTPDownloadRequest>)request;

/// Hiding deadly initializers.
POSRX_HTTPREQUEST_TYPED_INIT_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
