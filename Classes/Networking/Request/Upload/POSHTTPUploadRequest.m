//
//  POSHTTPUpload.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPUploadRequest.h"
#import "POSHTTPGateway.h"
#import "NSException+POSRx.h"
#import "NSObject+POSRx.h"

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
    if (@available(iOS 8, *)) {
        task = [gateway.foregroundSession uploadTaskWithStreamedRequest:request];
    } else {
        task = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:gateway
                                       startImmediately:NO];
    }
    return task;
}

@end

#pragma mark -

@interface POSHTTPUploadRequest ()
@property (nonatomic, copy) NSInputStream *(^bodyStreamBuilder)(void);
@end

@implementation POSHTTPUploadRequest

- (instancetype)initWithMethod:(POSHTTPRequestMethod *)method
                    bodyStream:(NSInputStream *(^)(void))bodyStream
                      progress:(void (^)(POSProgressValue *))progress
                  headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(bodyStream);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                            method:method
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
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return [self uploadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end

#pragma mark -

@implementation POSMutableHTTPUploadRequest

- (instancetype)init {
    return [super initWithType:POSHTTPRequestTypePUT
                        method:nil
                          body:nil
                  headerFields:nil];
}

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return [self uploadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end
