//
//  POSHTTPRequest.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"
#import "POSHTTPRequestMethod.h"
#import "POSHTTPRequestPacketOptions.h"
#import "POSHTTPGateway.h"
#import "POSProgressValue.h"

NS_ASSUME_NONNULL_BEGIN

@class POSHTTPRequest;

uint64_t const POSProgressValueUnknownUnitsCount = UINT64_MAX;

typedef NSURLSessionTask * _Nullable (^POSURLSessionTaskBuilder)(
    NSURL *hostURL,
    id<POSHTTPGateway> gateway,
    POSHTTPRequestPacketOptions * _Nullable options,
    NSError **error);

typedef NSMutableURLRequest * _Nullable (^POSURLRequestBuilder)(
    NSURL *hostURL,
    POSHTTPRequestPacketOptions * _Nullable options);

@interface POSHTTPRequest ()

@property (nonatomic, readonly, copy) POSURLSessionTaskBuilder taskBuilder;

@end

@implementation POSHTTPRequest

- (instancetype)initWithTaskBuilder:(POSURLSessionTaskBuilder)taskBuilder {
    POS_CHECK(taskBuilder);
    if (self = [super init]) {
        _taskBuilder = [taskBuilder copy];
    }
    return self;
}

#pragma mark - POSHTTPRequest

- (nullable NSURLSessionTask *)taskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(nullable POSHTTPRequestPacketOptions *)options
                                     error:(NSError **)error {
    POS_CHECK(hostURL);
    POS_CHECK(gateway);
    return _taskBuilder(hostURL, gateway, options, error);
}

@end

#pragma mark -

@interface POSHTTPRequestBuilder ()

@property (nonatomic, readonly) NSString *HTTPMethodName;
@property (nonatomic, readonly) POSURLSessionTaskBuilder taskBuilder;
@property (nonatomic, nullable) POSHTTPRequestMethod *method;
@property (nonatomic, nullable) NSData *body;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, nullable, copy) void (^fileHandler)(NSURL *fileLocation);
@property (nonatomic, nullable, copy) void (^downloadProgress)(POSProgressValue progress);
@property (nonatomic, nullable, copy) void (^uploadProgress)(POSProgressValue progress);

@end

@implementation POSHTTPRequestBuilder

- (POSHTTPRequest *)build {
    return [[POSHTTPRequest alloc] initWithTaskBuilder:self.taskBuilder];
}

- (NSString *)HTTPMethodName {
    return @"GET";
}

- (instancetype)withMethod:(nullable POSHTTPRequestMethod *)method {
    _method = method;
    return self;
}

- (instancetype)withBody:(nullable NSData *)body {
    _body = body;
    return self;
}

- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields {
    _headerFields = [headerFields copy];
    return self;
}

- (POSURLRequestBuilder)requestBuilder {
    __auto_type URIMethod = self.method;
    __auto_type HTTPMethodName = self.HTTPMethodName;
    __auto_type requestHeaderFields = self.headerFields;
    __auto_type body = self.body;
    return ^NSMutableURLRequest * _Nullable (NSURL *hostURL, POSHTTPRequestPacketOptions * _Nullable options) {
        NSURL *fullURL = [hostURL pos_URLByAppendingMethod:URIMethod withExtraURLQuery:options.URLQuery];
        NSTimeInterval responseTimeout = options.responseTimeout != nil ? options.responseTimeout.doubleValue : 30.0;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:fullURL
                                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                timeoutInterval:responseTimeout];
        request.HTTPMethod = HTTPMethodName;
        NSDictionary *allHeaderFields = options.headerFields;
        if (requestHeaderFields) {
            NSMutableDictionary *headerFields = [requestHeaderFields mutableCopy];
            [headerFields addEntriesFromDictionary:options.headerFields];
            allHeaderFields = headerFields;
        }
        request.allHTTPHeaderFields = allHeaderFields;
        request.HTTPBody = body;
        return request;
    };
}

- (POSURLSessionTaskBuilder)taskBuilder {
    POSURLRequestBuilder requestBuilder = [[self requestBuilder] copy];
    return ^NSURLSessionTask * _Nullable(NSURL *hostURL,
                                         id<POSHTTPGateway> gateway,
                                         POSHTTPRequestPacketOptions * _Nullable options,
                                         NSError **error) {
        NSURLRequest *request = requestBuilder(hostURL, options);
        return [gateway.foregroundSession dataTaskWithRequest:request];
    };
}

@end

#pragma mark -

@implementation POSHTTPHEAD

- (NSString *)HTTPMethodName {
    return @"HEAD";
}

@end

#pragma mark -

@implementation POSHTTPGETFile

- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSProgressValue progress))downloadProgress {
    self.downloadProgress = downloadProgress;
    return self;
}

- (instancetype)withFileHandler:(void (^ _Nullable)(NSURL *fileLocation))fileHandler {
    self.fileHandler = fileHandler;
    return self;
}

- (POSURLSessionTaskBuilder)taskBuilder {
    POSURLRequestBuilder requestBuilder = [[self requestBuilder] copy];
    return ^NSURLSessionTask * _Nullable(NSURL *hostURL,
                                         id<POSHTTPGateway> gateway,
                                         POSHTTPRequestPacketOptions * _Nullable options,
                                         NSError **error) {
        NSURLRequest *request = requestBuilder(hostURL, options);
        return [gateway.foregroundSession downloadTaskWithRequest:request];
    };
}

@end

#pragma mark -

@implementation POSHTTPPOST

- (NSString *)HTTPMethodName {
    return @"POST";
}

@end

#pragma mark -

@implementation POSHTTPPUT

- (NSString *)HTTPMethodName {
    return @"PUT";
}

- (instancetype)withUploadProgress:(void (^ _Nullable)(POSProgressValue))uploadProgress {
    self.uploadProgress = uploadProgress;
    return self;
}

@end

NS_ASSUME_NONNULL_END
