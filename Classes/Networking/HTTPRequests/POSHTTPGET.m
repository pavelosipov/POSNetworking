//
//  POSHTTPGET.m
//  POSNetworking
//
//  Created by Pavel Osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGET.h"
#import "POSHTTPGateway.h"
#import "NSURLSessionTask+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPGET

+ (id<POSHTTPRequest>)request {
    return [[[POSHTTPGET alloc] init] build];
}

- (instancetype)init {
    return [super initWithHTTPMethod:@"GET"];
}

@end

@interface POSHTTPGETFile ()
@property (nonatomic, nullable, copy) void (^downloadProgress)(POSHTTPRequestProgress progress);
@property (nonatomic, nullable, copy) void (^fileHandler)(NSURL *fileLocation);
@end

@implementation POSHTTPGETFile

- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSHTTPRequestProgress progress))downloadProgress {
    self.downloadProgress = [downloadProgress copy];
    return self;
}

- (instancetype)withFileHandler:(void (^ _Nullable)(NSURL *fileLocation))fileHandler {
    self.fileHandler = [fileHandler copy];
    return self;
}

- (POSURLSessionTaskFactory)URLSessionTaskFactory {
    __auto_type downloadProgress = _downloadProgress;
    __auto_type fileHandler = _fileHandler;
    return ^NSURLSessionTask * _Nullable(NSURLRequest *request, id<POSHTTPGateway> gateway, NSError **error) {
        NSURLSessionTask *task = [gateway.foregroundSession downloadTaskWithRequest:request];
        task.pos_downloadProgress = downloadProgress;
        task.pos_downloadCompletionHandler = fileHandler;
        return task;
    };
}

@end

NS_ASSUME_NONNULL_END
