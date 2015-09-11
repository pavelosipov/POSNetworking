//
//  NSObject+POSRx.h
//  POSRx
//
//  Created by Osipov on 07.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSubject;
@class POSHTTPTaskProgress;

@protocol POSURLSession <NSObject>
@property (nonatomic, readonly) RACSubject *posrx_invalidateSubject;
@end

@protocol POSURLSessionTask <NSObject>

@property (nonatomic, readonly, copy) NSURLRequest *posrx_originalRequest;
@property (nonatomic, readonly, copy) NSURLRequest *posrx_currentRequest;
@property (nonatomic, setter=posrx_setResponse:) NSHTTPURLResponse *posrx_response;
@property (nonatomic, setter=posrx_setAllowUntrustedSSLCertificates:) NSNumber *posrx_allowUntrustedSSLCertificates;

@property (nonatomic, copy, setter=posrx_setUploadProgressHandler:) void (^posrx_uploadProgressHandler)(POSHTTPTaskProgress *progress);
@property (nonatomic, copy, setter=posrx_setCompletionHandler:) void (^posrx_completionHandler)(NSError *error);
@property (nonatomic, copy, setter=posrx_setBodyStreamBuilder:) NSInputStream *(^posrx_bodyStreamBuilder)();
@property (nonatomic, copy, setter=posrx_setResponseHandler:) NSURLSessionResponseDisposition (^posrx_responseHandler)(NSURLResponse *response);
@property (nonatomic, copy, setter=posrx_setDataHandler:) void (^posrx_dataHandler)(NSData *data);
@property (nonatomic, copy, setter=posrx_setDownloadProgressHandler:) void (^posrx_downloadProgressHandler)(POSHTTPTaskProgress *progress);
@property (nonatomic, copy, setter=posrx_setDownloadCompletionHandler:) void (^posrx_downloadCompletionHandler)(NSURL *fileLocation);

- (void)posrx_start;
- (void)posrx_cancel;

@end

@interface NSObject (POSURLSession) <POSURLSession>
@end

@interface NSObject (POSURLSessionTask) <POSURLSessionTask>
@end