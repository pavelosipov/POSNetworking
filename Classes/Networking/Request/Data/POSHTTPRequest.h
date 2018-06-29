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

/// Represents request to remote server.
@protocol POSHTTPRequest <NSObject>

/// Method which will be appended to host's base URL (for ex. "/users/?sort=ASC").
@property (nonatomic, readonly, nullable) POSHTTPRequestMethod *method;

/// Request's body.
@property (nonatomic, readonly, nullable) NSData *body;

/// Request's headers, which will be appedned to or override default host headers.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *headerFields;

/// Notifies how many bytes were received from remote host.
@property (nonatomic, readonly, nullable) void (^downloadProgress)(POSProgressValue progress);

/// Notifies how many bytes were sent to remote host.
@property (nonatomic, readonly, nullable) void (^uploadProgress)(POSProgressValue progress);

/// Creates network task using one of NSURLSessions inside POSHTTPGateway.
- (nullable NSURLSessionTask *)taskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(nullable POSHTTPRequestPacketOptions *)options
                                     error:(NSError **)error;

@end

#pragma mark -

@interface POSHTTPRequestBuilder : NSObject

- (id<POSHTTPRequest>)build;

- (instancetype)withMethod:(nullable POSHTTPRequestMethod *)method;
- (instancetype)withBody:(nullable NSData *)body;
- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields;

@end

@interface POSHTTPHEAD : POSHTTPRequestBuilder
@end

@interface POSHTTPGET : POSHTTPRequestBuilder
@end

@interface POSHTTPGETFile : POSHTTPRequestBuilder

- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSProgressValue progress))downloadProgress;

@end

@interface POSHTTPPOST : POSHTTPRequestBuilder
@end

@interface POSHTTPPUT : POSHTTPRequestBuilder

- (instancetype)withUploadProgress:(void (^ _Nullable)(POSProgressValue progress))uploadProgress;

@end

NS_ASSUME_NONNULL_END
