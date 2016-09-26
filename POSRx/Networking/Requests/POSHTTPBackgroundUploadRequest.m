//
//  POSHTTPBackgroundUpload.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPBackgroundUploadRequest.h"
#import "POSHTTPBackgroundUploadDescription.h"
#import "POSHTTPGateway.h"
#import "NSException+POSRx.h"
#import "NSObject+POSRx.h"
#import <objc/runtime.h>

static char kPOSFileLocationKey;
static char kPOSUserInfoKey;

#pragma mark -

@interface POSHTTPRequest (Hidden)
- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options;
@end

#pragma mark -

@interface POSHTTPRequest (POSHTTPBackgroundUpload) <POSHTTPBackgroundUploadRequest>
@property (nonatomic, copy) NSURL *fileLocation;
@property (nonatomic) id<NSObject, NSCoding> userInfo;
@end

@implementation POSHTTPRequest (POSHTTPBackgroundUpload)

- (NSURL *)fileLocation {
    return objc_getAssociatedObject(self, &kPOSFileLocationKey);
}

- (void)setFileLocation:(NSURL *)fileLocation {
    POSRX_CHECK(fileLocation);
    objc_setAssociatedObject(self, &kPOSFileLocationKey, fileLocation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id<NSObject,NSCoding>)userInfo {
    return objc_getAssociatedObject(self, &kPOSUserInfoKey);
}

- (void)setUserInfo:(id<NSObject,NSCoding>)userInfo {
    objc_setAssociatedObject(self, &kPOSUserInfoKey, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)posrx_decodeWithCoder:(NSCoder *)aDecoder {
    NSURL *fileLocation = [aDecoder decodeObjectForKey:@"fileLocation"];
    NSParameterAssert(fileLocation);
    self.fileLocation = fileLocation;
    self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
}

- (void)posrx_encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fileLocation forKey:@"fileLocation"];
    if (self.userInfo) {
        [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    }
}

- (id<POSURLSessionTask>)backgroundUploadTaskWithURL:(NSURL *)hostURL
                                          forGateway:(id<POSHTTPGateway>)gateway
                                             options:(POSHTTPRequestOptions *)options
                                               error:(NSError **)error {
    NSMutableURLRequest *request = [self requestWithURL:hostURL options:options];
    NSURLSessionUploadTask *task = nil;
    for (NSUInteger attempts = 0; !task && attempts < 3; ++attempts) {
        task = [gateway.backgroundSession uploadTaskWithRequest:request fromFile:self.fileLocation];
    }
    if (!task) {
        if (error) {
            *error = [NSError
                      errorWithDomain:POSRxErrorDomain
                      code:POSHTTPSystemError
                      userInfo:@{NSLocalizedDescriptionKey: @"Background session is unable to create NSURLSessionUploadTask."}];
        }
        return nil;
    }
    POSHTTPBackgroundUploadDescription *description = [[POSHTTPBackgroundUploadDescription alloc]
                                                       initWithRequest:self
                                                       hostURL:hostURL
                                                       options:options];
    task.taskDescription = [description asString];
    return task;
}

@end

#pragma mark -

@interface POSHTTPBackgroundUploadRequest ()
@property (nonatomic, copy) void (^progressHandler)(POSProgressValue *progress);
@end

@implementation POSHTTPBackgroundUploadRequest
@dynamic fileLocation;
@dynamic userInfo;

#pragma mark Lifecycle

- (instancetype)initWithMethod:(POSHTTPRequestMethod *)method
                  fileLocation:(NSURL *)fileLocation
                      progress:(void (^)(POSProgressValue *))progress
                  headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(fileLocation);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                            method:method
                              body:nil
                      headerFields:headerFields]) {
        self.fileLocation = fileLocation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self posrx_decodeWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [self posrx_encodeWithCoder:aCoder];
}

#pragma mark POSHTTPRequest

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return [self backgroundUploadTaskWithURL:hostURL forGateway:gateway options:options error:error];
}

@end

#pragma mark -

@implementation POSMutableHTTPBackgroundUploadRequest
@dynamic fileLocation;
@dynamic userInfo;

#pragma mark Lifecycle

- (instancetype)initWithFileLocation:(NSURL *)fileLocation {
    POSRX_CHECK(fileLocation);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                            method:nil
                              body:nil
                      headerFields:nil]) {
        self.fileLocation = fileLocation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self posrx_decodeWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [self posrx_encodeWithCoder:aCoder];
}

#pragma mark POSHTTPRequest

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return [self backgroundUploadTaskWithURL:hostURL forGateway:gateway options:options error:error];
}

@end

#pragma mark -

@interface POSRecoveredHTTPBackgroundUploadRequest ()
@property (nonatomic) NSURLSessionUploadTask *sessionTask;
@end

@implementation POSRecoveredHTTPBackgroundUploadRequest
@dynamic uploadProgressHandler;

- (nullable instancetype)initWithRecoveredTask:(NSURLSessionUploadTask *)sessionTask {
    POSRX_CHECK(sessionTask);
    POSHTTPBackgroundUploadDescription *description = [POSHTTPBackgroundUploadDescription fromString:sessionTask.taskDescription];
    NSParameterAssert(description);
    if (!description) {
        return nil;
    }
    if (self = [super initWithRequest:description.request]) {
        _sessionTask = sessionTask;
        _hostURL = description.hostURL;
        _options = description.options;
        self.fileLocation = description.request.fileLocation;
        self.userInfo = description.request.userInfo;
    }
    return self;
}

#pragma mark Public

- (void)cancel {
    [_sessionTask cancel];
}

#pragma mark POSHTTPRequest

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options
                               error:(NSError **)error {
    return _sessionTask;
}

@end

