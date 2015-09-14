//
//  POSHTTPBackgroundUpload.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPBackgroundUpload.h"
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

@interface POSHTTPRequest (POSHTTPBackgroundUpload) <POSHTTPBackgroundUpload>
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
        [aCoder encodeObject:self.fileLocation forKey:@"userInfo"];
    }
}

- (id<POSURLSessionTask>)backgroundUploadTaskWithURL:(NSURL *)hostURL
                                          forGateway:(id<POSHTTPGateway>)gateway
                                             options:(POSHTTPRequestOptions *)options {
    NSMutableURLRequest *request = [self requestWithURL:hostURL options:options];
    NSURLSessionUploadTask *task = [gateway.backgroundSession uploadTaskWithRequest:request fromFile:self.fileLocation];
    POSHTTPBackgroundUploadDescription *description = [POSHTTPBackgroundUploadDescription new];
    description.request = self;
    description.hostURL = hostURL;
    description.options = options;
    task.taskDescription = [description asString];
    return task;
}

@end

#pragma mark -

@interface POSHTTPBackgroundUpload ()
@property (nonatomic, copy) void (^progressHandler)(POSHTTPRequestProgress *progress);
@end

@implementation POSHTTPBackgroundUpload
@dynamic fileLocation;
@dynamic userInfo;

#pragma mark Lifecycle

- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                          fileLocation:(NSURL *)fileLocation
                              progress:(void (^)(POSHTTPRequestProgress *progress))progress
                          headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(fileLocation);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                    endpointMethod:endpointMethod
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
                             options:(POSHTTPRequestOptions *)options {
    return [self backgroundUploadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end

#pragma mark -

@implementation POSMutableHTTPBackgroundUpload
@dynamic fileLocation;
@dynamic userInfo;

#pragma mark Lifecycle

- (instancetype)initFileLocation:(NSURL *)fileLocation {
    POSRX_CHECK(fileLocation);
    if (self = [super init]) {
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
                             options:(POSHTTPRequestOptions *)options {
    return [self backgroundUploadTaskWithURL:hostURL forGateway:gateway options:options];
}

@end

#pragma mark -

@interface POSRecoveredHTTPBackgroundUpload ()
@property (nonatomic) NSURLSessionUploadTask *sessionTask;
@end

@implementation POSRecoveredHTTPBackgroundUpload

- (instancetype)initWithRecoveredTask:(NSURLSessionUploadTask *)sessionTask {
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

#pragma mark POSHTTPRequest

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options {
    return _sessionTask;
}

@end

