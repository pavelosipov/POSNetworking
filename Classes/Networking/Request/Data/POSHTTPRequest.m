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

typedef NSURLSessionTask * _Nullable (^POSURLSessionTaskBuilder)(
    POSHTTPRequest *request,
    NSURL *hostURL,
    id<POSHTTPGateway> gateway,
    POSHTTPRequestPacketOptions * _Nullable options,
    NSError **error);

@interface POSHTTPRequest : NSObject <POSHTTPRequest>

@property (nonatomic, readonly) NSString *HTTPMethodName;
@property (nonatomic, readonly, copy) POSURLSessionTaskBuilder taskBuilder;

POS_INIT_UNAVAILABLE

@end

@implementation POSHTTPRequest

@synthesize method = _method;
@synthesize body = _body;
@synthesize headerFields = _headerFields;
@synthesize downloadProgress = _downloadProgress;
@synthesize uploadProgress = _uploadProgress;

- (instancetype)initWithHTTPMethodName:(NSString *)HTTPMethodName
                                method:(nullable POSHTTPRequestMethod *)method
                                  body:(nullable NSData *)body
                          headerFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields
                      downloadProgress:(void (^ _Nullable)(POSProgressValue progress))downloadProgress
                        uploadProgress:(void (^ _Nullable)(POSProgressValue progress))uploadProgress
                           taskBuilder:(POSURLSessionTaskBuilder)taskBuilder {
    POS_CHECK(HTTPMethodName);
    POS_CHECK(taskBuilder);
    if (self = [super init]) {
        _HTTPMethodName = [HTTPMethodName copy];
        _method = method;
        _body = body;
        _headerFields = [headerFields copy];
        _downloadProgress = [downloadProgress copy];
        _uploadProgress = [uploadProgress copy];
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
    return _taskBuilder(self, hostURL, gateway, options, error);
}

#pragma mark - Private

- (NSMutableURLRequest *)p_requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestPacketOptions *)options {
    NSURL *fullURL = [hostURL pos_URLByAppendingMethod:_method withExtraURLQuery:options.URLQuery];
    NSTimeInterval responseTimeout = options.responseTimeout != nil ? options.responseTimeout.doubleValue : 30.0;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:fullURL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:responseTimeout];
    request.HTTPMethod = _HTTPMethodName;
    NSDictionary *allHeaderFields;
    if (!_headerFields) {
        allHeaderFields = options.headerFields;
    } else {
        NSMutableDictionary *headerFields = [_headerFields mutableCopy];
        [headerFields addEntriesFromDictionary:options.headerFields];
        allHeaderFields = headerFields;
    }
    if (allHeaderFields) {
        request.allHTTPHeaderFields = allHeaderFields;
    }
    if (_body) {
        request.HTTPBody = _body;
    }
    return request;
}

@end

#pragma mark -

@interface POSHTTPRequestBuilder ()

@property (nonatomic, readonly) NSString *methodName;
@property (nonatomic, readonly) POSURLSessionTaskBuilder taskBuilder;
@property (nonatomic, nullable) POSHTTPRequestMethod *method;
@property (nonatomic, nullable) NSData *body;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, nullable, copy) void (^downloadProgress)(POSProgressValue progress);
@property (nonatomic, nullable, copy) void (^uploadProgress)(POSProgressValue progress);

@end

@implementation POSHTTPRequestBuilder

- (POSHTTPRequest *)build {
    return [[POSHTTPRequest alloc]
        initWithHTTPMethodName:self.methodName
        method:_method
        body:_body
        headerFields:_headerFields
        downloadProgress:_downloadProgress
        uploadProgress:_uploadProgress
        taskBuilder:self.taskBuilder];
}

- (NSString *)methodName {
    return @"GET";
}

- (POSURLSessionTaskBuilder)taskBuilder {
    return ^NSURLSessionTask * _Nullable(POSHTTPRequest *request,
                                         NSURL *hostURL,
                                         id<POSHTTPGateway> gateway,
                                         POSHTTPRequestPacketOptions * _Nullable options,
                                         NSError **error) {
        NSURLRequest *URLRequest = [request p_requestWithURL:hostURL options:options];
        return [gateway.foregroundSession dataTaskWithRequest:URLRequest];
    };
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

@end

#pragma mark -

@implementation POSHTTPHEAD

- (NSString *)methodName {
    return @"HEAD";
}

@end

#pragma mark -

@implementation POSHTTPGET
@end

#pragma mark -

@implementation POSHTTPGETFile

- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSProgressValue progress))downloadProgress {
    self.downloadProgress = downloadProgress;
    return self;
}

@end


/*
NSString *POSStringFromHTTPRequestType(POSHTTPRequestType type) {
    switch (type) {
        case POSHTTPRequestTypeGET:  return @"GET";
        case POSHTTPRequestTypeHEAD: return @"HEAD";
        case POSHTTPRequestTypePOST: return @"POST";
        case POSHTTPRequestTypePUT:  return @"PUT";
    }
}
*/

uint64_t const POSProgressValueUnknownUnitsCount = UINT64_MAX;

NS_ASSUME_NONNULL_END
