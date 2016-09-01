//
//  POSHTTPRequest.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPGateway;
@protocol POSURLSessionTask;

@class POSHTTPRequestMethod;
@class POSHTTPRequestOptions;
@class POSProgressValue;

/// Available types of HTTP requests.
typedef NS_ENUM(NSInteger, POSHTTPRequestType) {
    POSHTTPRequestTypeGET = 0,
    POSHTTPRequestTypeHEAD,
    POSHTTPRequestTypePOST,
    POSHTTPRequestTypePUT
};

/// Represents request to remote server.
@protocol POSHTTPRequest <NSObject>

/// Type of HTTP request.
@property (nonatomic, readonly) POSHTTPRequestType type;

/// Method which will be appended to host's base URL (for ex. "/users/?sort=ASC").
@property (nonatomic, readonly, nullable) POSHTTPRequestMethod *method;

/// Request's body.
@property (nonatomic, readonly, nullable) NSData *body;

/// Request's headers, which will be appedned to or override default host headers.
@property (nonatomic, readonly, nullable) NSDictionary *headerFields;

/// Notifies how many bytes were received from remote host.
@property (nonatomic, readonly, nullable, copy) void (^downloadProgressHandler)(POSProgressValue *progress);

/// Notifies how many bytes were sent to remote host.
@property (nonatomic, readonly, nullable, copy) void (^uploadProgressHandler)(POSProgressValue *progress);

/// Creates network task using one of NSURLSessions inside POSHTTPGateway.
- (nullable id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                                   forGateway:(id<POSHTTPGateway>)gateway
                                      options:(nullable POSHTTPRequestOptions *)options
                                        error:(NSError **)error;

@end

#pragma mark -

/// Helper class to create standard HTTP requests.
@interface POSHTTPRequest : NSObject <POSHTTPRequest, NSCoding>

/// The designated initializer which init request as GET request
/// without any custom values for properties.
- (instancetype)init;

/// Copying initializer.
- (instancetype)initWithRequest:(id<POSHTTPRequest>)request;

/// The designated initializer.
- (instancetype)initWithType:(POSHTTPRequestType)type
                      method:(nullable POSHTTPRequestMethod *)method
                        body:(nullable NSData *)body
                headerFields:(nullable NSDictionary *)headerFields;

/// The designated initializer.
- (instancetype)initWithType:(POSHTTPRequestType)type
                      method:(nullable POSHTTPRequestMethod *)method
                        body:(nullable NSData *)body
                headerFields:(nullable NSDictionary *)headerFields
            downloadProgress:(nullable void (^)(POSProgressValue *progress))downloadProgress
              uploadProgress:(nullable void (^)(POSProgressValue *progress))uploadProgress;

@end

#pragma mark -

/// Mutable version of POSHTTPRequest.
@interface POSMutableHTTPRequest : POSHTTPRequest

/// Type of HTTP request.
@property (nonatomic) POSHTTPRequestType type;

/// Method which will be appended to host's base URL (for ex. "/users/?sort=ASC"). May be nil.
@property (nonatomic, nullable) POSHTTPRequestMethod *method;

/// Request's body. May be nil.
@property (nonatomic, nullable, copy) NSData *body;

/// Request's headers, which will be appedned to or override default host headers. May be nil.
@property (nonatomic, nullable, copy) NSDictionary *headerFields;

/// Notifies how many bytes were received from remote host.
@property (nonatomic, nullable, copy) void (^downloadProgressHandler)(POSProgressValue *progress);

/// Notifies how many bytes were sent to remote host.
@property (nonatomic, nullable, copy) void (^uploadProgressHandler)(POSProgressValue *progress);

@end

NS_ASSUME_NONNULL_END

#define POSRX_HTTPREQUEST_TYPED_INIT_UNAVAILABLE                                                                        \
- (instancetype)initWithType:(POSHTTPRequestType)type                                                            \
                      method:(nullable POSHTTPRequestMethod *)method                                             \
                        body:(nullable NSData *)body                                                             \
                headerFields:(nullable NSDictionary *)headerFields NS_UNAVAILABLE;                               \
                                                                                                                 \
- (instancetype)initWithType:(POSHTTPRequestType)type                                                            \
                      method:(nullable POSHTTPRequestMethod *)method                                             \
                        body:(nullable NSData *)body                                                             \
                headerFields:(nullable NSDictionary *)headerFields                                               \
            downloadProgress:(nullable void (^)(POSProgressValue *progress))downloadProgress               \
              uploadProgress:(nullable void (^)(POSProgressValue *progress))uploadProgress NS_UNAVAILABLE;

