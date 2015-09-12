//
//  POSHTTPUpload.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPUpload.h"
#import "POSHTTPGateway.h"
#import "NSException+POSRx.h"
#import "NSObject+POSRx.h"
#import "POSSystemInfo.h"

#pragma mark -

@interface POSHTTPRequest (Hidden)
- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options;
@end

#pragma mark -

@interface POSHTTPRequest (POSHTTPUpload) <POSHTTPUpload>
@end

@implementation POSHTTPRequest (POSHTTPUpload)
@dynamic bodyStream;
@dynamic progress;

- (id<POSURLSessionTask>)uploadTaskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(POSHTTPRequestOptions *)options {
    NSMutableURLRequest *request = [self requestWithURL:hostURL options:options];
    request.HTTPBodyStream = self.bodyStream();
    id<POSURLSessionTask> task;
    if ([POSSystemInfo isOutdatedOS]) {
        task = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:self
                                       startImmediately:NO];
    } else {
        task = [gateway.foregroundSession uploadTaskWithStreamedRequest:request];
    }
    task.posrx_uploadProgressHandler = self.progress;
    return task;
}

@end

#pragma mark -

@interface POSHTTPUpload ()
@property (nonatomic, copy) NSInputStream *(^bodyStream)();
@property (nonatomic, copy) void (^progress)(POSHTTPRequestProgress *progress);
@end

@implementation POSHTTPUpload

POSRX_DEADLY_INITIALIZER(initWithType:(POSHTTPRequestType)type
                         endpointMethod:(NSString *)endpointMethod
                         body:(NSData *)body
                         headerFields:(NSDictionary *)headerFields)

- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                            bodyStream:(NSInputStream *(^)())bodyStream
                              progress:(void (^)(POSHTTPRequestProgress *))progress
                          headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(bodyStream);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                    endpointMethod:endpointMethod
                              body:nil
                      headerFields:headerFields]) {
        _bodyStream = [bodyStream copy];
        _progress = [progress copy];
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

@implementation POSMutableHTTPUpload

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
