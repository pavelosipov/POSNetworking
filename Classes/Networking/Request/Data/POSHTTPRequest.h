//
//  POSHTTPRequest.h
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>
#import "POSProgressValue.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPGateway;

@class POSHTTPRequestMethod;
@class POSHTTPRequestPacketOptions;

/// Represents repeatable request to remote server.
@protocol POSHTTPRequest <NSObject>

/// Creates network task using one of NSURLSessions inside POSHTTPGateway.
- (nullable NSURLSessionTask *)taskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(nullable POSHTTPRequestPacketOptions *)options
                                     error:(NSError **)error;

@end

#pragma mark -

@interface POSHTTPRequest : NSObject <POSHTTPRequest>

@property (nonatomic, nullable, readonly) void (^fileHandler)(NSURL *fileLocation);
@property (nonatomic, nullable, readonly) void (^downloadProgress)(POSProgressValue progress);
@property (nonatomic, nullable, readonly) void (^uploadProgress)(POSProgressValue progress);

POS_INIT_UNAVAILABLE

@end

#pragma mark -

///
/// @brief      Builds request with specified attributes.
///
/// @discussion It creates GET request by default, but POSHTTPGET builder is more appropriate
///             for that purpose because of more declarative name.
///
@interface POSHTTPRequestBuilder : NSObject

- (id<POSHTTPRequest>)build;

/// Method which will be appended to host's base URL (for ex. "/users/?sort=ASC").
- (instancetype)withMethod:(nullable POSHTTPRequestMethod *)method;

/// Request's body.
- (instancetype)withBody:(nullable NSData *)body;

/// Request's headers, which will be appedned to or override default host or gateway headers.
- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields;

@end

typedef POSHTTPRequestBuilder POSHTTPGET;

#pragma mark -

@interface POSHTTPGETFile : POSHTTPGET

/// Notifies how many bytes were received from remote host.
- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSProgressValue progress))downloadProgress;

/// Handler of the downloaded file at specified path.
- (instancetype)withFileHandler:(void (^ _Nullable)(NSURL *fileLocation))fileHandler;

@end

#pragma mark -

@interface POSHTTPHEAD : POSHTTPRequestBuilder
@end

#pragma mark -

@interface POSHTTPPOST : POSHTTPRequestBuilder
@end

#pragma mark -

@interface POSHTTPPUT : POSHTTPRequestBuilder

/// Notifies how many bytes were sent to remote host.
- (instancetype)withUploadProgress:(void (^ _Nullable)(POSProgressValue progress))uploadProgress;

/// Creates stream for the HTTP request's body.
- (instancetype)withBodyStream:(NSInputStream *(^ _Nullable)(void))streamFactory;

@end

NS_ASSUME_NONNULL_END
