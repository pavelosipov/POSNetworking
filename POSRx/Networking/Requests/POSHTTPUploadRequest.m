//
//  POSHTTPUpload.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPUploadRequest.h"
#import "POSHTTPGateway.h"
#import "NSException+POSRx.h"
#import "NSObject+POSRx.h"
#import "POSSystemInfo.h"

#pragma mark -

@interface POSHTTPRequest (Hidden)
- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options;
@end

#pragma mark -

@interface POSHTTPRequest (POSHTTPUpload) <POSHTTPUploadRequest>
@end

@implementation POSHTTPRequest (POSHTTPUpload)
@dynamic bodyStreamBuilder;

- (id<POSURLSessionTask>)uploadTaskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(POSHTTPRequestOptions *)options {
    NSMutableURLRequest *request = [self requestWithURL:hostURL options:options];
    request.HTTPBodyStream = self.bodyStreamBuilder();
    id<POSURLSessionTask> task;
    if ([POSSystemInfo isOutdatedOS]) {
        task = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:gateway
                                       startImmediately:NO];
    } else {
        task = [gateway.foregroundSession uploadTaskWithStreamedRequest:request];
    }
    return task;
}

@end

#pragma mark -

@interface POSHTTPUploadRequest ()
@property (nonatomic, copy) NSInputStream *(^bodyStreamBuilder)();
@end

@implementation POSHTTPUploadRequest

POSRX_DEADLY_INITIALIZER(init)

POSRX_DEADLY_INITIALIZER(initWithRequest:(id<POSHTTPRequest>)request)

POSRX_DEADLY_INITIALIZER(initWithType:(POSHTTPRequestType)type
                         endpointMethod:(NSString *)endpointMethod
                         body:(NSData *)body
                         headerFields:(NSDictionary *)headerFields)

POSRX_DEADLY_INITIALIZER(initWithType:(POSHTTPRequestType)type
                         endpointMethod:(NSString *)endpointMethod
                         body:(NSData *)body
                         headerFields:(NSDictionary *)headerFields
                         downloadProgress:(void (^)(POSHTTPRequestProgress *))downloadProgress
                         uploadProgress:(void (^)(POSHTTPRequestProgress *))uploadProgress)

- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                            bodyStream:(NSInputStream *(^)())bodyStream
                              progress:(void (^)(POSHTTPRequestProgress *))progress
                          headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(bodyStream);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                    endpointMethod:endpointMethod
                              body:nil
                      headerFields:headerFields
                  downloadProgress:nil
                    uploadProgress:progress]) {
        _bodyStreamBuilder = [bodyStream copy];
    }
    return self;
}

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options {
    return [self uploadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end

#pragma mark -

@implementation POSMutableHTTPUploadRequest

- (instancetype)init {
    return [super initWithType:POSHTTPRequestTypePUT
                endpointMethod:nil
                          body:nil
                  headerFields:nil];
}

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options {
    return [self uploadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end
