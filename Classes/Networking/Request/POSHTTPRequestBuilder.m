//
//  POSHTTPRequestBuilder.m
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestBuilder.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPRequestProgress.h"
#import "POSHTTPResponse.h"
#import "POSHTTPGateway.h"

#import "NSError+POSNetworking.h"
#import "NSHTTPURLResponse+POSNetworking.h"
#import "NSDictionary+POSNetworking.h"
#import "NSURL+POSNetworking.h"
#import "NSURLSessionTask+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSURLRequest * _Nullable (^POSURLRequestFactory)(NSURL *hostURL, POSHTTPRequestOptions * _Nullable options);

@interface POSHTTPRequestBuilder ()

@property (nonatomic, readonly) NSString *HTTPMethodName;
@property (nonatomic, nullable) NSData *body;
@property (nonatomic, nullable) POSHTTPRequestOptions *requestOptions;
@property (nonatomic, nullable, copy) POSHTTPCustomResponseHandler customResponseHandler;
@property (nonatomic, nullable, copy) POSHTTPCustomMetadataHandler customMetadataHandler;
@property (nonatomic, nullable, copy) POSHTTPDataHandler dataHandler;

@end

@implementation POSHTTPRequestBuilder

- (POSHTTPRequest *)build {
    POSURLRequestFactory requestFactory = self.requestFactory;
    POSURLSessionTaskFactory taskFactory = self.URLSessionTaskFactory;
    __auto_type requestTaskFactory = ^NSURLSessionTask * _Nullable(NSURL *hostURL,
                                                                   id<POSHTTPGateway> gateway,
                                                                   POSHTTPRequestOptions * _Nullable options,
                                                                   NSError **error) {
        NSURLRequest *request = requestFactory(hostURL, options);
        NSURLSessionTask *task = taskFactory(request, gateway, error);
        return task;
    };
    return [[POSHTTPRequest alloc]
        initWithTaskFactory:requestTaskFactory
        responseHandler:self.responseHandler
        options:_requestOptions];
}

- (NSString *)HTTPMethodName {
    return @"GET";
}

- (POSHTTPResponseHandler)responseHandler {
    POSHTTPDataHandler dataHandler = _dataHandler;
    POSHTTPMetadataHandler metadataHandler = self.metadataHandler;
    POSHTTPResponseHandler responseHandler = ^id _Nullable (POSHTTPResponse *response, NSError **error) {
        if (!metadataHandler(response.metadata, error)) {
            return nil;
        }
        if (dataHandler && !response.data) {
            POSAssignError(error, [NSError pos_serverErrorWithTag:@"nodata" format:@"No data in reponse."]);
            return nil;
        } else if (dataHandler) {
            return dataHandler(response.data, error);
        }
        return response;
    };
    if (!_customResponseHandler) {
        return responseHandler;
    }
    POSHTTPCustomResponseHandler customHandler = _customResponseHandler;
    return ^id _Nullable(POSHTTPResponse *response, NSError **error) {
        return customHandler(responseHandler, response, error);
    };
}

- (POSHTTPMetadataHandler)metadataHandler {
    POSHTTPMetadataHandler metadataHandler = ^BOOL(NSHTTPURLResponse *metadata, NSError **error) {
        if (![metadata pos_contains2XXStatusCode]) {
            POSAssignError(error, [NSError pos_serverErrorWithHTTPStatusCode:metadata.statusCode]);
            return NO;
        }
        return YES;
    };
    if (!_customMetadataHandler) {
        return metadataHandler;
    }
    POSHTTPCustomMetadataHandler customHandler = _customMetadataHandler;
    return ^BOOL(NSHTTPURLResponse *metadata, NSError **error) {
        return customHandler(metadataHandler, metadata, error);
    };
}

- (instancetype)withBody:(nullable NSData *)body {
    self.body = body;
    return self;
}

- (instancetype)withOptions:(nullable POSHTTPRequestOptions *)options {
    self.requestOptions = options;
    return self;
}

- (POSURLRequestFactory)requestFactory {
    __auto_type HTTPMethodName = self.HTTPMethodName;
    __auto_type body = self.body;
    return ^NSMutableURLRequest * _Nullable (NSURL *hostURL, POSHTTPRequestOptions * _Nullable options) {
        NSURL *fullURL = [hostURL pos_URLByAppendingPath:options.URLPath query:options.URLQuery];
        NSTimeInterval responseTimeout = options.responseTimeout != nil ? options.responseTimeout.doubleValue : 30.0;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:fullURL
                                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                timeoutInterval:responseTimeout];
        request.HTTPMethod = HTTPMethodName;
        request.allHTTPHeaderFields = options.headerFields;
        request.HTTPBody = body;
        return request;
    };
}

- (instancetype)withResponseHandler:(nullable POSHTTPCustomResponseHandler)handler {
    self.customResponseHandler = [handler copy];
    return self;
}

- (instancetype)withMetadataHandler:(nullable POSHTTPCustomMetadataHandler)handler {
    self.customMetadataHandler = [handler copy];
    return self;
}

- (instancetype)withDataHandler:(nullable POSHTTPDataHandler)handler {
    self.dataHandler = [handler copy];
    return self;
}

- (POSURLSessionTaskFactory)URLSessionTaskFactory {
    return ^NSURLSessionTask * _Nullable(NSURLRequest *request, id<POSHTTPGateway> gateway, NSError **error) {
        return [gateway.foregroundSession dataTaskWithRequest:request];
    };
}

@end

NS_ASSUME_NONNULL_END
