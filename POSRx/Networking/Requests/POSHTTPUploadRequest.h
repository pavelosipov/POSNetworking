//
//  POSHTTPUploadRequest.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

/// Protocol for making foreground upload requests.
@protocol POSHTTPUploadRequest <POSHTTPRequest>

/// Stream for the HTTP request's body.
@property (nonatomic, readonly, copy) NSInputStream *(^bodyStreamBuilder)();

@end

/// Request to make foreground uploads using PUT HTTP method with multipart form data.
@interface POSHTTPUploadRequest : POSHTTPRequest <POSHTTPUploadRequest>

/// The designated initializer.
- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                     bodyStreamBuilder:(NSInputStream *(^)())bodyStreamBuilder
                          headerFields:(NSDictionary *)headerFields;

@end

/// Mutable version of POSHTTPUploadRequest.
@interface POSMutableHTTPUploadRequest : POSMutableHTTPRequest <POSHTTPUploadRequest>

/// Stream for the HTTP request's body.
@property (nonatomic, copy) NSInputStream *(^bodyStreamBuilder)();

/// Creates HTTP PUT request without HTTPBody or HTTPBodyStream.
- (instancetype)init;

@end
