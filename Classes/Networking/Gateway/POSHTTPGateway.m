//
//  POSHTTPGateway.m
//  POSNetworking
//
//  Created by Pavel Osipov on 22.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGateway.h"
#import "POSHTTPGatewayOptions.h"
#import "POSHTTPRequest.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPResponse.h"
#import "POSHTTPResponseOptions.h"

#import "NSError+POSNetworking.h"
#import "NSURLCache+POSNetworking.h"
#import "NSURLSession+POSNetworking.h"
#import "NSURLSessionTask+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPGateway () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLConnectionDelegate>
@end

@implementation POSHTTPGateway

@synthesize options = _options;
@synthesize foregroundSession = _foregroundSession;
@synthesize backgroundSession = _backgroundSession;

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
      backgroundSessionIdentifier:(nullable NSString *)ID {
    if (self = [super initWithScheduler:scheduler safetyPredicate:nil]) {
        NSURLSessionConfiguration *foregroundConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.underlyingQueue = scheduler.queue;
        foregroundConfiguration.URLCache = [NSURLCache pos_leaksFreeCache];
        _foregroundSession = [NSURLSession sessionWithConfiguration:foregroundConfiguration
                                                           delegate:self
                                                      delegateQueue:operationQueue];
        if (ID) {
            NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration
                                                                  backgroundSessionConfigurationWithIdentifier:ID];
            backgroundConfiguration.URLCache = [NSURLCache pos_leaksFreeCache];
            _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration
                                                               delegate:self
                                                          delegateQueue:operationQueue];
        }
    }
    return self;
}

#pragma mark - POSHTTPGateway

- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                      options:(nullable POSHTTPGatewayOptions *)options {
    POS_CHECK(request);
    POS_CHECK(hostURL);
    POSHTTPGatewayOptions *mergedOptions = [POSHTTPGatewayOptions merge:_options with:options];
    mergedOptions = [POSHTTPGatewayOptions merge:mergedOptions withRequestOptions:request.options];
    return [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSError *error = nil;
            NSURLSessionTask *sessionTask = [request taskWithURL:hostURL
                                                      forGateway:self
                                                         options:mergedOptions.requestOptions
                                                           error:&error];
            if (!sessionTask) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
                return nil;
            }
            POSHTTPResponse *simulatedResponse = [mergedOptions.responseOptions probeSimulationForRequest:request
                                                                                                      URL:hostURL];
            if (simulatedResponse) {
                [subscriber sendNext:simulatedResponse];
                [subscriber sendCompleted];
                return nil;
            }
            NSMutableData *responseData = [[NSMutableData alloc] init];
            @weakify(sessionTask);
            sessionTask.pos_allowUntrustedSSLCertificates = mergedOptions.requestOptions.allowUntrustedSSLCertificates;
            sessionTask.pos_completionHandler = ^(NSError *error) {
                @strongify(sessionTask);
                NSURL *responseURL = sessionTask.originalRequest.URL ?: hostURL;
                if (error) {
                    [subscriber sendError:[NSError pos_networkErrorWithURL:responseURL reason:error]];
                } else if (!error && !sessionTask.response) {
                    [subscriber sendError:[NSError pos_systemErrorWithFormat:@"Bad response from URL=%@", responseURL]];
                } else {
                    POSHTTPResponse *response = [[POSHTTPResponse alloc] initWithData:responseData
                                                                             metadata:(id)sessionTask.response];
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                }
            };
            sessionTask.pos_dataHandler = ^(NSData *data) {
                [responseData appendData:data];
            };
            [sessionTask pos_start];
            return [RACDisposable disposableWithBlock:^{
                [sessionTask cancel];
            }];
        }];
    } scheduler:self.scheduler];
}

- (void)invalidateBackgroundTasksWithCompletionHandler:(dispatch_block_t)completionHandler {
    POS_CHECK(completionHandler);
    if (!_backgroundSession) {
        completionHandler();
        return;
    }
    [_backgroundSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *dataTasks,
                                                        NSArray<NSURLSessionUploadTask *> *uploadTasks,
                                                        NSArray<NSURLSessionDownloadTask *> *downloadTasks) {
        for (NSURLSessionDataTask *task in dataTasks) {
            [task cancel];
        }
        for (NSURLSessionUploadTask *task in uploadTasks) {
            [task cancel];
        }
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            [task cancel];
        }
        completionHandler();
    }];
}

- (RACSignal *)invalidateForced:(BOOL)forced {
    RACSignal *invalidateSignal;
    if (_backgroundSession != nil) {
        invalidateSignal = [[RACSignal
            merge:@[_foregroundSession.pos_invalidateSubject, _backgroundSession.pos_invalidateSubject]]
            replayLast];
    } else {
        invalidateSignal = [_foregroundSession.pos_invalidateSubject replayLast];
    }
    if (forced) {
        [_foregroundSession invalidateAndCancel];
        [_backgroundSession invalidateAndCancel];
    } else {
        [_foregroundSession finishTasksAndInvalidate];
        [_backgroundSession finishTasksAndInvalidate];
    }
    return invalidateSignal;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    if (error) {
        [session.pos_invalidateSubject sendError:error];
    } else {
        [session.pos_invalidateSubject sendCompleted];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (task.pos_completionHandler) {
        task.pos_completionHandler(error);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (task.pos_uploadProgress) {
        task.pos_uploadProgress((POSHTTPRequestProgress) {
            .ready = totalBytesSent,
            .total = totalBytesExpectedToSend
        });
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * __nullable))completionHandler {
    if (task.pos_bodyStreamBuilder) {
        completionHandler(task.pos_bodyStreamBuilder());
    } else {
        completionHandler(nil);
    }
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable))completionHandler {
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (dataTask.pos_dataHandler) {
        dataTask.pos_dataHandler(data);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        task.pos_allowUntrustedSSLCertificates.boolValue) {
        completionHandler(NSURLSessionAuthChallengeUseCredential,
                          [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
        return;
    }
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    if (downloadTask.pos_downloadCompletionHandler) {
        downloadTask.pos_downloadCompletionHandler(location);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (downloadTask.pos_downloadProgress) {
        downloadTask.pos_downloadProgress((POSHTTPRequestProgress) {
            .ready = bytesWritten,
            .total = totalBytesWritten
        });
    }
}

@end

NS_ASSUME_NONNULL_END
