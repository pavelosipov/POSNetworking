//
//  NSURLSessionTask+POSNetworking.m
//  POSNetworking
//
//  Created by p.osipov on 29/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSURLSessionTask+POSNetworking.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

static char kAllowUntrustedSSLCertificates;

static char kDownloadProgressKey;
static char kUploadProgressKey;
static char kCompletionHandlerKey;
static char kDataHandlerKey;
static char kBodyStreamBuilderKey;
static char kDownloadCompletionHandlerKey;

@implementation NSURLSessionTask (POSNetworking)

- (void)pos_start {
    switch (self.state) {
        case NSURLSessionTaskStateRunning:
        case NSURLSessionTaskStateCanceling:
            break;
        case NSURLSessionTaskStateSuspended:
            [self resume];
            break;
        case NSURLSessionTaskStateCompleted:
            if (self.pos_completionHandler) {
                self.pos_completionHandler(self.error);
            }
            break;
    }
}

- (nullable NSNumber *)pos_allowUntrustedSSLCertificates {
    return objc_getAssociatedObject(self, &kAllowUntrustedSSLCertificates);
}

- (void)pos_setAllowUntrustedSSLCertificates:(nullable NSNumber *)allowed {
    objc_setAssociatedObject(self, &kAllowUntrustedSSLCertificates, allowed, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^ _Nullable)(POSHTTPRequestProgress))pos_uploadProgress {
    return objc_getAssociatedObject(self, &kUploadProgressKey);
}

- (void)pos_setUploadProgress:(void (^ _Nullable)(POSHTTPRequestProgress))uploadProgress {
    objc_setAssociatedObject(self, &kUploadProgressKey, uploadProgress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^ _Nullable)(NSError *))pos_completionHandler {
    return objc_getAssociatedObject(self, &kCompletionHandlerKey);
}

- (void)pos_setCompletionHandler:(void (^ _Nullable)(NSError *))completionHandler {
    objc_setAssociatedObject(self, &kCompletionHandlerKey, completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInputStream * _Nullable (^ _Nullable)(void))pos_bodyStreamBuilder {
    return objc_getAssociatedObject(self, &kBodyStreamBuilderKey);
}

- (void)pos_setBodyStreamBuilder:(NSInputStream * _Nullable(^ _Nullable)(void))bodyStreamBuilder {
    objc_setAssociatedObject(self, &kBodyStreamBuilderKey, bodyStreamBuilder, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^ _Nullable)(NSData *))pos_dataHandler {
    return objc_getAssociatedObject(self, &kDataHandlerKey);
}

- (void)pos_setDataHandler:(void (^ _Nullable)(NSData *))dataHandler {
    objc_setAssociatedObject(self, &kDataHandlerKey, dataHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^ _Nullable)(POSHTTPRequestProgress))pos_downloadProgress {
    return objc_getAssociatedObject(self, &kDownloadProgressKey);
}

- (void)pos_setDownloadProgress:(void (^ _Nullable)(POSHTTPRequestProgress))downloadProgress {
    objc_setAssociatedObject(self, &kDownloadProgressKey, downloadProgress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^ _Nullable)(NSURL *))pos_downloadCompletionHandler {
    return objc_getAssociatedObject(self, &kDownloadCompletionHandlerKey);
}

- (void)pos_setDownloadCompletionHandler:(void (^ _Nullable)(NSURL *))completionHandler {
    objc_setAssociatedObject(self, &kDownloadCompletionHandlerKey, completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
