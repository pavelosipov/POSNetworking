//
//  POSHTTPRequest.h
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>
#import "POSHTTPRequestProgress.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPGateway;

@class POSHTTPResponse;
@class POSHTTPRequestOptions;

/// Factory block for creating NSURLSessionTask with specified parameters.
/// Factory block for building request-specific NSURLSessionTask.
typedef NSURLSessionTask * _Nullable (^POSURLSessionTaskFactory)(
    NSURLRequest *request,
    id<POSHTTPGateway> gateway,
    NSError **error);

/// Block for handling incomming responses from previously created NSURLSessionTask.
typedef id _Nullable (^POSHTTPResponseHandler)(POSHTTPResponse *response, NSError **error);

/// Represents repeatable request to remote server.
@protocol POSHTTPRequest <NSObject>

@property (nonatomic, readonly) NSString *HTTPMethod;
@property (nonatomic, readonly, nullable) POSHTTPRequestOptions *options;
@property (nonatomic, readonly) POSHTTPResponseHandler responseHandler;

/// Creates network task using one of NSURLSessions inside POSHTTPGateway.
- (nullable NSURLSessionTask *)taskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(nullable POSHTTPRequestOptions *)options
                                     error:(NSError **)error;

@end

#pragma mark -

@interface POSHTTPRequest : NSObject <POSHTTPRequest>

- (instancetype)initWithHTTPMethod:(NSString *)HTTPMethod
                       taskFactory:(POSURLSessionTaskFactory)taskFactory
                   responseHandler:(POSHTTPResponseHandler)responseHandler
                           options:(nullable POSHTTPRequestOptions *)options NS_DESIGNATED_INITIALIZER;

POS_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
