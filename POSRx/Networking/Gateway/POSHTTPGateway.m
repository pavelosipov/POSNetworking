//
//  POSHTTPGateway.m
//  POSRx
//
//  Created by Pavel Osipov on 22.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGateway.h"
#import "POSHTTPBackgroundUploadRequest.h"
#import "POSHTTPRequestExecutionOptions.h"
#import "POSHTTPRequestSimulationOptions.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPResponse.h"
#import "POSHTTPRequestProgress.h"
#import "POSTask.h"
#import "POSSystemInfo.h"
#import "NSObject+POSRx.h"
#import "NSError+POSRx.h"
#import "NSException+POSRx.h"
#import "NSURLCache+POSRx.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const POSRxErrorDomain = @"com.github.pavelosipov.POSRxErrorDomain";
NSInteger const POSHTTPSystemError = 101;

#pragma mark -

@interface NSOperationQueue (POSHTTPGateway)
@end

@implementation NSOperationQueue (POSHTTPGateway)

+ (NSOperationQueue *)pos_operationQueueForScheduler:(RACTargetQueueScheduler *)scheduler {
    if (![POSSystemInfo isOutdatedOS]) {
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        operationQueue.underlyingQueue = scheduler.queue;
        return operationQueue;
    } else {
        POSRX_CHECK([scheduler isEqual:[RACScheduler mainThreadScheduler]] ||
                    scheduler.queue == dispatch_get_main_queue());
        return [NSOperationQueue mainQueue];
    }
}

@end

#pragma mark -

@interface POSHTTPGateway () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLConnectionDelegate>
@property (nonatomic) RACSignal *working;
@property (nonatomic) NSMutableSet *actualTasks;
@property (nonatomic) NSURLSession *foregroundSession;
@property (nonatomic) NSURLSession *backgroundSession;
@end

@implementation POSHTTPGateway

#pragma mark Lifecycle

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
      backgroundSessionIdentifier:(nullable NSString *)ID {
    if (self = [super initWithScheduler:scheduler]) {
        _actualTasks = [NSMutableSet new];
        NSURLSessionConfiguration *foregroundSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *operationQueue = [NSOperationQueue pos_operationQueueForScheduler:scheduler];
        foregroundSessionConfiguration.URLCache = [NSURLCache posrx_leaksFreeCache];
        _foregroundSession = [NSURLSession
                              sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                              delegate:self
                              delegateQueue:operationQueue];
        if (ID) {
            NSURLSessionConfiguration *backgroundSessionConfiguration =
            [POSSystemInfo isOutdatedOS] ?
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSURLSessionConfiguration backgroundSessionConfiguration:ID] :
#pragma clang diagnostic pop
            [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:ID];
            backgroundSessionConfiguration.URLCache = [NSURLCache posrx_leaksFreeCache];
            _backgroundSession = [NSURLSession
                                  sessionWithConfiguration:backgroundSessionConfiguration
                                  delegate:self
                                  delegateQueue:operationQueue];
        }
    }
    return self;
}

#pragma mark MRCHTTPGateway

- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                      options:(nullable POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    POSRX_CHECK(hostURL);
    return [POSTask createTask:^RACSignal * _Nonnull(POSTask * _Nonnull task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSError *error = nil;
            id<POSURLSessionTask> sessionTask = [request taskWithURL:hostURL
                                                          forGateway:self
                                                             options:options.HTTP
                                                               error:&error];
            if (!sessionTask) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
                return nil;
            }
            POSRX_CHECK(sessionTask);
            POSHTTPResponse *simulatedResponse = [options.simulation probeSimulationWithURL:sessionTask.posrx_originalRequest.URL];
            if (simulatedResponse) {
                [subscriber sendNext:simulatedResponse];
                [subscriber sendCompleted];
                return nil;
            }
            NSMutableData *responseData = [NSMutableData new];
            @weakify(sessionTask);
            if (options.HTTP.allowUntrustedSSLCertificates) {
                sessionTask.posrx_allowUntrustedSSLCertificates = options.HTTP.allowUntrustedSSLCertificates;
            }
            if (request.downloadProgressHandler) {
                sessionTask.posrx_downloadProgressHandler = request.downloadProgressHandler;
            }
            if (request.uploadProgressHandler) {
                sessionTask.posrx_uploadProgressHandler = request.uploadProgressHandler;
            }
            sessionTask.posrx_completionHandler = ^(NSError *error) {
                @strongify(sessionTask);
                NSURL *responseURL = sessionTask.posrx_originalRequest.URL ?: hostURL;
                if (error) {
                    [subscriber sendError:[error errorWithURL:responseURL]];
                } else if (!error && !sessionTask.posrx_response) {
                    [subscriber
                     sendError:[NSError
                                errorWithDomain:POSRxErrorDomain
                                code:POSHTTPSystemError
                                userInfo:@{NSURLErrorKey:responseURL,
                                           NSLocalizedDescriptionKey:@"Response doesn't have metadata."}]];
                } else {
                    POSHTTPResponse *response = [[POSHTTPResponse alloc]
                                                 initWithData:responseData
                                                 metadata:sessionTask.posrx_response];
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                }
            };
            sessionTask.posrx_dataHandler = ^(NSData *data) {
                [responseData appendData:data];
            };
            sessionTask.posrx_responseHandler = ^NSURLSessionResponseDisposition(NSURLResponse *URLResponse) {
                return NSURLSessionResponseAllow;
            };
            [sessionTask posrx_start];
            return [RACDisposable disposableWithBlock:^{
                [sessionTask posrx_cancel];
            }];
        }];
    } scheduler:self.scheduler];
}

- (void)recoverBackgroundUploadRequestsUsingBlock:(void(^)(NSArray *uploadRequests))block {
    POSRX_CHECK(block);
    [_backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSMutableArray *requests = [NSMutableArray new];
        for (NSURLSessionUploadTask *task in uploadTasks) {
            POSRecoveredHTTPBackgroundUploadRequest *request = [[POSRecoveredHTTPBackgroundUploadRequest alloc]
                                                         initWithRecoveredTask:task];
            if (request) {
                [requests addObject:request];
            } else {
                [task cancel];
            }
        }
        block(requests);
    }];
}

- (RACSignal *)invalidateCancelingRequests:(BOOL)cancelPendingRequests {
    if (cancelPendingRequests) {
        [_foregroundSession invalidateAndCancel];
        [_backgroundSession invalidateAndCancel];
    } else {
        [_foregroundSession finishTasksAndInvalidate];
        [_backgroundSession finishTasksAndInvalidate];
    }
    if (_backgroundSession) {
        return [RACSignal merge:@[_foregroundSession.posrx_invalidateSubject,
                                  _backgroundSession.posrx_invalidateSubject]];
    } else {
        return _foregroundSession.posrx_invalidateSubject;
    }
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    if (error) {
        [session.posrx_invalidateSubject sendError:error];
    } else {
        [session.posrx_invalidateSubject sendCompleted];
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (task.posrx_completionHandler) {
        task.posrx_completionHandler(error);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (task.posrx_uploadProgressHandler) {
        task.posrx_uploadProgressHandler([[POSHTTPRequestProgress alloc]
                                          initWithReadyUnits:totalBytesSent
                                          totalUnits:totalBytesExpectedToSend]);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * __nullable))completionHandler {
    if (task.posrx_bodyStreamBuilder) {
        completionHandler(task.posrx_bodyStreamBuilder());
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
    if (dataTask.posrx_responseHandler) {
        completionHandler(dataTask.posrx_responseHandler(response));
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (dataTask.posrx_dataHandler) {
        dataTask.posrx_dataHandler(data);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        [task.posrx_allowUntrustedSSLCertificates boolValue]) {
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
    if (downloadTask.posrx_downloadCompletionHandler) {
        downloadTask.posrx_downloadCompletionHandler(location);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (downloadTask.posrx_downloadProgressHandler) {
        downloadTask.posrx_downloadProgressHandler([[POSHTTPRequestProgress alloc]
                                                    initWithReadyUnits:totalBytesWritten
                                                    totalUnits:totalBytesExpectedToWrite]);
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    connection.posrx_response = (id)response;
    if (connection.posrx_responseHandler) {
        connection.posrx_responseHandler(response);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection.posrx_dataHandler) {
        connection.posrx_dataHandler(data);
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (connection.posrx_uploadProgressHandler) {
        connection.posrx_uploadProgressHandler([[POSHTTPRequestProgress alloc]
                                                initWithReadyUnits:totalBytesWritten
                                                totalUnits:totalBytesExpectedToWrite]);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection.posrx_completionHandler) {
        connection.posrx_completionHandler(nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection.posrx_completionHandler) {
        connection.posrx_completionHandler(error);
    }
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    if (connection.posrx_bodyStreamBuilder) {
        return connection.posrx_bodyStreamBuilder();
    }
    return nil;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
            [connection.posrx_allowUntrustedSSLCertificates boolValue]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end

NS_ASSUME_NONNULL_END
