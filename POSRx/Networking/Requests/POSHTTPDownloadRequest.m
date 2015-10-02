//
//  POSHTTPDownloadRequest.m
//  POSRx
//
//  Created by Pavel Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPDownloadRequest.h"
#import "POSHTTPGateway.h"
#import "NSObject+POSRx.h"

@interface POSHTTPRequest (Hidden)
- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options;
@end

#pragma mark -

@interface POSHTTPRequest (POSHTTPDownload) <POSHTTPDownloadRequest>
@end

@implementation POSHTTPRequest (POSHTTPDownload)
@dynamic fileHandler;

- (id<POSURLSessionTask>)downloadTaskWithURL:(NSURL *)hostURL
                                  forGateway:(id<POSHTTPGateway>)gateway
                                     options:(POSHTTPRequestOptions *)options {
    NSMutableURLRequest *request = [self requestWithURL:hostURL options:options];
    id<POSURLSessionTask> task = [gateway.foregroundSession downloadTaskWithRequest:request];
    task.posrx_downloadCompletionHandler = self.fileHandler;
    return task;
}

@end

#pragma mark -

@interface POSHTTPDownloadRequest ()
@property (nonatomic, copy) void (^fileHandler)(NSURL *location);
@end

@implementation POSHTTPDownloadRequest

#pragma mark Lifecycle

- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                           destination:(void (^)(NSURL *))destination
                              progress:(void (^)(POSHTTPRequestProgress *progress))progress
                          headerFields:(NSDictionary *)headerFields {
    if (self = [super initWithType:POSHTTPRequestTypeGET
                    endpointMethod:endpointMethod
                              body:nil
                      headerFields:headerFields
                  downloadProgress:progress
                    uploadProgress:nil]) {
        _fileHandler = [destination copy];
    }
    return self;
}

#pragma mark POSHTTPRequest

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return [self downloadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end

#pragma mark -

@implementation POSMutableHTTPDownloadRequest

#pragma mark Lifecycle

- (instancetype)init {
    return [super initWithType:POSHTTPRequestTypeGET
                endpointMethod:nil
                          body:nil
                  headerFields:nil];
}

#pragma mark POSHTTPRequest

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return [self downloadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end
