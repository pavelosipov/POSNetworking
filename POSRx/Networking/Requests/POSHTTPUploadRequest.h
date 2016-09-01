//
//  POSHTTPUpload.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"
#import "POSContracts.h"

NS_ASSUME_NONNULL_BEGIN

/// Protocol for making foreground upload requests.
@protocol POSHTTPUploadRequest <POSHTTPRequest>

/// Stream for the HTTP request's body.
@property (nonatomic, readonly, nullable, copy) NSInputStream *(^bodyStreamBuilder)();

@end

#pragma mark -

/// Request to make foreground uploads using PUT HTTP method with multipart form data.
@interface POSHTTPUploadRequest : POSHTTPRequest <POSHTTPUploadRequest>

/// The designated initializer for foreground upload.
- (instancetype)initWithMethod:(nullable POSHTTPRequestMethod *)method
                    bodyStream:(NSInputStream *(^)())bodyStream
                      progress:(nullable void (^)(POSProgressValue *progress))progress
                  headerFields:(nullable NSDictionary *)headerFields;

/// Hidnig copying initializer.
- (instancetype)initWithRequest:(id<POSHTTPRequest>)request NS_UNAVAILABLE;

/// Hidnig other initializers.
POSRX_INIT_UNAVAILABLE;
POSRX_HTTPREQUEST_TYPED_INIT_UNAVAILABLE;

@end

#pragma mark -

/// Mutable version of POSHTTPUpload request.
@interface POSMutableHTTPUploadRequest : POSMutableHTTPRequest <POSHTTPUploadRequest>

/// Stream for the HTTP request's body.
@property (nonatomic, copy, nullable) NSInputStream *(^bodyStreamBuilder)();

/// Creates HTTP PUT request without HTTPBody or HTTPBodyStream.
- (instancetype)init;

/// Hidnig copying initializer.
- (instancetype)initWithRequest:(id<POSHTTPRequest>)request NS_UNAVAILABLE;

/// Hiding deadly initializers.
POSRX_HTTPREQUEST_TYPED_INIT_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
