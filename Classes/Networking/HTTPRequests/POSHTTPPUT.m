//
//  POSHTTPPUT.m
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPPUT.h"
#import "POSHTTPGateway.h"
#import "NSURLSessionTask+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPPUT ()
@property (nonatomic, nullable, copy) void (^uploadProgress)(POSHTTPRequestProgress progress);
@end

@implementation POSHTTPPUT

- (instancetype)init {
    return [super initWithHTTPMethod:@"PUT"];
}

- (instancetype)withUploadProgress:(void (^ _Nullable)(POSHTTPRequestProgress))uploadProgress {
    self.uploadProgress = uploadProgress;
    return self;
}

@end

#pragma mark -

@interface POSHTTPPUTForeground ()
@property (nonatomic, nullable, copy) NSInputStream * _Nullable (^streamFactory)(void);
@end

@implementation POSHTTPPUTForeground

- (instancetype)withBodyStream:(NSInputStream * _Nullable (^ _Nullable)(void))streamFactory {
    self.streamFactory = streamFactory;
    return self;
}

- (POSURLSessionTaskFactory)URLSessionTaskFactory {
    __auto_type uploadProgress = self.uploadProgress;
    __auto_type streamFactory = self.streamFactory;
    return ^NSURLSessionTask * _Nullable(NSURLRequest *request, id<POSHTTPGateway> gateway, NSError **error) {
        NSURLSessionTask *task = [gateway.foregroundSession uploadTaskWithStreamedRequest:request];
        task.pos_uploadProgress = uploadProgress;
        task.pos_bodyStreamBuilder = streamFactory;
        return task;
    };
}

@end

#pragma mark -

@interface POSHTTPPUTBackground ()
@property (nonatomic, readonly) NSURL *fileLocation;
@end

@implementation POSHTTPPUTBackground

- (instancetype)initWithFile:(NSURL *)fileLocation {
    if (self = [super init]) {
        _fileLocation = fileLocation;
    }
    return self;
}

- (POSURLSessionTaskFactory)URLSessionTaskFactory {
    __auto_type uploadProgress = self.uploadProgress;
    NSURL *fileLocation = _fileLocation;
    return ^NSURLSessionTask * _Nullable(NSURLRequest *request, id<POSHTTPGateway> gateway, NSError **error) {
        NSURLSessionUploadTask *task = nil;
        for (NSUInteger attempts = 0; !task && attempts < 3; ++attempts) {
            task = [gateway.backgroundSession uploadTaskWithRequest:request fromFile:fileLocation];
        }
        if (!task) {
            POSAssignError(error, [NSError pos_systemErrorWithFormat:
                                   @"Background session is unable to create NSURLSessionUploadTask."]);
            return nil;
        }
        task.pos_uploadProgress = uploadProgress;
        return task;
    };
}

@end

NS_ASSUME_NONNULL_END
