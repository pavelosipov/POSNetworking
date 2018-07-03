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
typedef NSURLSessionTask * _Nullable (^POSHTTPRequestTaskFactory)(
    NSURL *hostURL,
    id<POSHTTPGateway> gateway,
    POSHTTPRequestOptions * _Nullable options,
    NSError **error);

/// Block for handling incomming responses from previously created NSURLSessionTask.
typedef id _Nullable (^POSHTTPResponseHandler)(POSHTTPResponse *response, NSError **error);

/// Represents repeatable request to remote server.
@protocol POSHTTPRequest <NSObject>

@property (nonatomic, readonly) POSHTTPRequestTaskFactory taskFactory;
@property (nonatomic, readonly) POSHTTPResponseHandler responseHandler;
@property (nonatomic, readonly, nullable) POSHTTPRequestOptions *options;

@end

#pragma mark -

@interface POSHTTPRequest : NSObject <POSHTTPRequest>

- (instancetype)initWithTaskFactory:(POSHTTPRequestTaskFactory)taskFactory
                    responseHandler:(POSHTTPResponseHandler)responseHandler
                            options:(nullable POSHTTPRequestOptions *)options NS_DESIGNATED_INITIALIZER;

POS_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
