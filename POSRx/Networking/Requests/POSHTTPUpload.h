//
//  POSHTTPUpload.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

@class POSHTTPTaskProgress;

/// Protocol for making foreground upload requests.
@protocol POSHTTPUpload <POSHTTPRequest>

/// Stream for the HTTP request's body.
@property (nonatomic, readonly, copy) NSInputStream *(^bodyStream)();

/// Uploading progress handler.
@property (nonatomic, readonly, copy) void (^progress)(POSHTTPTaskProgress *progress);

@end

/// Request to make foreground uploads using PUT HTTP method with multipart form data.
@interface POSHTTPUpload : POSHTTPRequest <POSHTTPUpload>

/// The designated initializer for foreground upload.
- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                            bodyStream:(NSInputStream *(^)())bodyStream
                              progress:(void (^)(POSHTTPTaskProgress *progress))progress
                          headerFields:(NSDictionary *)headerFields;

/// The designated initializer for foreground upload.

@end

/// Mutable version of POSHTTPUploadRequest.
@interface POSMutableHTTPUpload : POSMutableHTTPRequest <POSHTTPUpload>

/// Stream for the HTTP request's body.
@property (nonatomic, copy) NSInputStream *(^bodyStream)();

/// Uploading progress handler.
@property (nonatomic, copy) void (^progress)(POSHTTPTaskProgress *progress);

/// Creates HTTP PUT request without HTTPBody or HTTPBodyStream.
- (instancetype)init;

@end
