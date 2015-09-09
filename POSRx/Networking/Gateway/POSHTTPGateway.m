//
//  POSHTTPGateway.m
//  POSRx
//
//  Created by Pavel Osipov on 22.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGateway.h"
#import "POSHTTPUploadRequest.h"
#import "POSHTTPBackgroundUploadRequest.h"
#import "POSHTTPRequestExecutionOptions.h"
#import "POSHTTPRequestSimulationOptions.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPResponse.h"
#import "POSHTTPTaskProgress.h"
#import "NSObject+POSRx.h"
#import "NSException+POSRx.h"
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif

static NSString * const kHTTPTaskUploadProgressEvent    = @"UPG";
static NSString * const kHTTPTaskDownloadProgressEvent  = @"DPE";
static NSString * const kHTTPTaskDownloadCompletedEvent = @"DCE";

#pragma mark -

@interface UIDevice (POSRx)
@end

@implementation UIDevice (POSRx)

+ (BOOL)posrx_isFirmwareOutdated {
    return UIDevice.currentDevice.systemVersion.floatValue < 8.0;
}

@end

#pragma mark -

@interface NSError (POSRx)
@end

@implementation NSError (POSRx)

- (NSError *)errorWithURL:(NSURL *)URL {
    if (self.userInfo[NSURLErrorKey]) {
        return self;
    }
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
    if (!userInfo) {
        userInfo = [NSMutableDictionary new];
    }
    userInfo[NSURLErrorKey] = [URL copy];
    NSError *error = [NSError errorWithDomain:self.domain
                                         code:self.code
                                     userInfo:userInfo];
    return error;
}

@end

#pragma mark -

@interface POSHTTPTaskDescription : NSObject <NSCoding>

@property (nonatomic) id<POSHTTPBackgroundUploadRequest> request;
@property (nonatomic) NSURL *hostURL;
@property (nonatomic) POSHTTPRequestExecutionOptions *options;
@property (nonatomic) id<NSObject,NSCoding> userInfo;

+ (instancetype)fromString:(NSString *)description;
- (NSString *)asString;

@end

static NSString *MRCBuildHTTPTaskDescription(
    id<POSHTTPBackgroundUploadRequest> request,
    NSURL *hostURL,
    POSHTTPRequestExecutionOptions *options,
    id<NSObject,NSCoding> userInfo);

#pragma mark -

@interface POSHTTPTask : POSTask <POSHTTPDownloadTask, POSHTTPUploadTask>
@property (nonatomic) id<NSObject,NSCoding> userInfo;
@end

@implementation POSHTTPTask

- (RACSignal *)downloadProgress {
    return [self signalForEvent:kHTTPTaskDownloadProgressEvent];
}

- (RACSignal *)downloadCompleted {
    return [self signalForEvent:kHTTPTaskDownloadCompletedEvent];
}

- (RACSignal *)uploadProgress {
    return [self signalForEvent:kHTTPTaskUploadProgressEvent];
}

@end

@interface NSURLCache (POSRx)
@end

@implementation NSURLCache (POSRx)

+ (NSURLCache *)posrx_leaksFreeCache {
    // Preventing memory leaks as described at http://ubm.io/1mObM8d
    return [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
}

@end

#pragma mark - 

@interface POSHTTPGateway () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLConnectionDelegate, POSTaskExecutor>
@property (nonatomic) RACSignal *working;
@property (nonatomic) NSMutableSet *actualTasks;
@property (nonatomic) POSDirectTaskExecutor *taskExecutor;
@property (nonatomic) NSURLSession *foregroundSession;
@property (nonatomic) NSURLSession *backgroundSession;
@end

@implementation POSHTTPGateway

#pragma mark Lifecycle

- (instancetype)initWithScheduler:(RACScheduler *)scheduler backgroundSessionIdentifier:(NSString *)ID {
    if (self = [super initWithScheduler:scheduler]) {
        _actualTasks = [NSMutableSet new];
        _taskExecutor = [POSDirectTaskExecutor new];
        NSURLSessionConfiguration *foregroundSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        foregroundSessionConfiguration.URLCache = [NSURLCache posrx_leaksFreeCache];
        _foregroundSession = [NSURLSession
                              sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                              delegate:self
                              delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionConfiguration *backgroundSessionConfiguration =
            [UIDevice posrx_isFirmwareOutdated] ?
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSURLSessionConfiguration backgroundSessionConfiguration:ID] :
#pragma clang diagnostic pop
            [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:ID];
        backgroundSessionConfiguration.URLCache = [NSURLCache posrx_leaksFreeCache];
        _backgroundSession = [NSURLSession
                              sessionWithConfiguration:backgroundSessionConfiguration
                              delegate:self
                              delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)invalidateCancelingTasks:(BOOL)cancelPendingTasks {
    if (cancelPendingTasks) {
        [_foregroundSession invalidateAndCancel];
        [_backgroundSession invalidateAndCancel];
    } else {
        [_foregroundSession finishTasksAndInvalidate];
        [_backgroundSession finishTasksAndInvalidate];
    }
}

POSRX_DEADLY_INITIALIZER(initWithScheduler:(RACScheduler *)scheduler)
POSRX_DEADLY_INITIALIZER(initWithScheduler:(RACScheduler *)scheduler options:(POSScheduleProtectionOptions *)options)

#pragma mark MRCHTTPGateway

- (id<POSHTTPTask>)dataTaskWithRequest:(id<POSHTTPRequest>)request
                                toHost:(NSURL *)hostURL
                               options:(POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    POSRX_CHECK(hostURL);
    NSURLRequest *URLRequest = [request requestWithURL:hostURL options:options.HTTP];
    return [self p_taskWithRequest:URLRequest options:options taskBuilder:^id<POSURLTask>(POSTaskContext *context) {
        return [self.foregroundSession dataTaskWithRequest:URLRequest];
    }];
}

- (id<POSHTTPDownloadTask>)downloadTaskWithRequest:(id<POSHTTPRequest>)request
                                            toHost:(NSURL *)hostURL
                                           options:(POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    POSRX_CHECK(hostURL);
    NSURLRequest *URLRequest = [request requestWithURL:hostURL options:options.HTTP];
    return [self p_taskWithRequest:URLRequest options:options taskBuilder:^id<POSURLTask>(POSTaskContext *context) {
        id<POSURLTask> task = [self.foregroundSession downloadTaskWithRequest:URLRequest];
        task.posrx_downloadProgressHandler = ^(POSHTTPTaskProgress *progress) {
            [[context subjectForEvent:kHTTPTaskDownloadProgressEvent] sendNext:progress];
        };
        task.posrx_downloadCompletionHandler = ^(NSURL *fileLocation) {
            [[context subjectForEvent:kHTTPTaskDownloadCompletedEvent] sendNext:fileLocation];
        };
        return task;
    }];
}

- (id<POSHTTPUploadTask>)uploadTaskWithRequest:(id<POSHTTPUploadRequest>)request
                                        toHost:(NSURL *)hostURL
                                       options:(POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    POSRX_CHECK(hostURL);
    NSURLRequest *URLRequest = [request requestWithURL:hostURL options:options.HTTP];
    return [self p_uploadTaskWithRequest:URLRequest options:options taskBuilder:^id<POSURLTask>(POSTaskContext *context) {
        id<POSURLTask> task;
        if ([UIDevice posrx_isFirmwareOutdated]) {
            task = [[NSURLConnection alloc] initWithRequest:URLRequest
                                                   delegate:self
                                           startImmediately:NO];
        } else {
            task = [self.foregroundSession uploadTaskWithStreamedRequest:URLRequest];
        }
        return task;
    }];
}

- (id<POSHTTPUploadTask>)backgroundUploadTaskWithRequest:(id<POSHTTPBackgroundUploadRequest>)request
                                                  toHost:(NSURL *)hostURL
                                                 options:(POSHTTPRequestExecutionOptions *)options
                                                userInfo:(id<NSObject,NSCoding>)userInfo {
    POSRX_CHECK(request);
    POSRX_CHECK(hostURL);
    NSURLRequest *URLRequest = [request requestWithURL:hostURL options:options.HTTP];
    POSHTTPTask *task = [self p_uploadTaskWithRequest:URLRequest options:options taskBuilder:^id<POSURLTask>(POSTaskContext *context) {
        NSURLSessionUploadTask *task = [self.backgroundSession uploadTaskWithRequest:URLRequest fromFile:request.fileLocation];
        task.taskDescription = MRCBuildHTTPTaskDescription(request, hostURL, options, userInfo);
        return task;
    }];
    task.userInfo = userInfo;
    return task;
}

- (void)recoverBackgroundUploadTasksUsingBlock:(void (^)(NSArray *))block {
    POSRX_CHECK(block);
    @weakify(self);
    [_backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        @strongify(self);
        NSMutableArray *uploadHTTPTasks = [NSMutableArray new];
        for (NSURLSessionUploadTask *task in uploadTasks) {
            id<POSHTTPUploadTask> HTTPTask = [self p_recoverUploadTaskFromSessionTask:task];
            if (HTTPTask) {
                [uploadHTTPTasks addObject:HTTPTask];
            }
            NSLog(@"%@: recovered task in state: %@", self, @(task.state));
        }
        block(uploadHTTPTasks);
    }];
}

#pragma mark Private

- (id<POSHTTPUploadTask>)p_recoverUploadTaskFromSessionTask:(NSURLSessionTask *)sessionTask {
    POSHTTPTaskDescription *description = [POSHTTPTaskDescription fromString:sessionTask.taskDescription];
    if (!description) {
        [sessionTask cancel];
        return nil;
    }
    POSHTTPTask *task = [self
                         p_uploadTaskWithRequest:[description.request
                                                  requestWithURL:description.hostURL
                                                  options:description.options.HTTP]
                         options:description.options
                         taskBuilder:^id<POSURLTask>(POSTaskContext *context) { return sessionTask; }];
    task.userInfo = description.userInfo;
    return task;
}

- (POSHTTPTask *)p_uploadTaskWithRequest:(NSURLRequest *)request
                                 options:(POSHTTPRequestExecutionOptions *)options
                             taskBuilder:(id<POSURLTask>(^)(POSTaskContext *context))taskBuilder {
    return [self p_taskWithRequest:request options:options taskBuilder:^id<POSURLTask>(POSTaskContext *context) {
        id<POSURLTask> task = taskBuilder(context);
        task.posrx_uploadProgressHandler = ^(POSHTTPTaskProgress *progress) {
            [[context subjectForEvent:kHTTPTaskUploadProgressEvent] sendNext:progress];
        };
        return task;
    }];
}

- (POSHTTPTask *)p_taskWithRequest:(NSURLRequest *)request
                           options:(POSHTTPRequestExecutionOptions *)options
                       taskBuilder:(id<POSURLTask>(^)(POSTaskContext *context))taskBuilder {
    return [POSHTTPTask createTask:^RACSignal *(POSTaskContext *context) {
        NSURL *requestURL = request.URL;
        POSHTTPResponse *simulatedResponse = [options.simulation probeSimulationWithURL:requestURL];
        if (simulatedResponse) {
            return [RACSignal return:simulatedResponse];
        }
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            id<POSURLTask> task = taskBuilder(context);
            NSMutableData *responseData = [NSMutableData new];
            @weakify(task);
            if (options.HTTP.allowUntrustedSSLCertificates) {
                task.posrx_allowUntrustedSSLCertificates = options.HTTP.allowUntrustedSSLCertificates;
            }
            task.posrx_completionHandler = ^(NSError *error) {
                @strongify(task);
                if (!error) {
                    POSHTTPResponse *response = [[POSHTTPResponse alloc]
                                                 initWithData:responseData
                                                 metadata:task.posrx_response];
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[error errorWithURL:requestURL]];
                }
            };
            task.posrx_dataHandler = ^(NSData *data) {
                [responseData appendData:data];
            };
            task.posrx_responseHandler = ^NSURLSessionResponseDisposition(NSURLResponse *URLResponse) {
                return NSURLSessionResponseAllow;
            };
            [task posrx_start];
            return [RACDisposable disposableWithBlock:^{
                [task posrx_cancel];
            }];
        }];
    } scheduler:self.scheduler executor:self];
}

#pragma mark POSTaskExecutor

- (void)pushTask:(POSTask *)task {
    [_actualTasks addObject:task];
    [_taskExecutor pushTask:task];
    POSRX_CHECK([task isExecuting]);
    [[[task executing] takeUntilBlock:^BOOL(NSNumber *executing) {
        return executing.boolValue;
    }] subscribeCompleted:^{
        [_actualTasks removeObject:task];
    }];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
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
        task.posrx_uploadProgressHandler([[POSHTTPTaskProgress alloc]
                                          initWithReadyUnits:totalBytesSent
                                          totalUnits:totalBytesExpectedToSend]);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *))completionHandler {
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
 completionHandler:(void (^)(NSCachedURLResponse *))completionHandler {
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
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
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
        downloadTask.posrx_downloadProgressHandler([[POSHTTPTaskProgress alloc]
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
        connection.posrx_uploadProgressHandler([[POSHTTPTaskProgress alloc]
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

#pragma mark -

@implementation POSHTTPTaskDescription

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _request = [aDecoder decodeObjectForKey:@"request"];
        _hostURL = [aDecoder decodeObjectForKey:@"hostURL"];
        _options = [aDecoder decodeObjectForKey:@"options"];
        _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_request forKey:@"request"];
    [aCoder encodeObject:_hostURL forKey:@"hostURL"];
    if (_options) {
        [aCoder encodeObject:_options forKey:@"options"];
    }
    if (_userInfo) {
        [aCoder encodeObject:_userInfo forKey:@"userInfo"];
    }
}

+ (instancetype)fromString:(NSString *)description {
    if (!description) {
        return nil;
    }
    @try {
        NSData *data = [description dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) {
            return nil;
        }
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        return [unarchiver decodeObject];
    } @catch (NSException *exception) {
        return nil;
    }
}

- (NSString *)asString {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc ] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeRootObject:self];
    [archiver finishEncoding];
    return [[NSString alloc]
            initWithData:data
            encoding:NSUTF8StringEncoding];
}

@end

NSString *MRCBuildHTTPTaskDescription(
    id<POSHTTPBackgroundUploadRequest> request,
    NSURL *hostURL,
    POSHTTPRequestExecutionOptions *options,
    id<NSObject,NSCoding> userInfo) {
    POSHTTPTaskDescription *description = [POSHTTPTaskDescription new];
    description.request = request;
    description.hostURL = hostURL;
    description.options = options;
    description.userInfo = userInfo;
    return [description asString];
}
