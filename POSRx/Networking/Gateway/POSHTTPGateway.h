//
//  POSHTTPGateway.h
//  POSRx
//
//  Created by Pavel Osipov on 22.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSTask.h"

#pragma mark - Gateway

@protocol POSHTTPRequest;
@protocol POSHTTPUploadRequest;
@protocol POSHTTPBackgroundUploadRequest;
@class POSHTTPRequestExecutionOptions;

/// Base protocol for all kind of tasks.
@protocol POSHTTPTask <POSTask>
/// Some user-specific data, which was assigned during task creation.
@property (nonatomic, readonly) id<NSObject,NSCoding> userInfo;
@end

/// Represents properties of downloading task.
@protocol POSHTTPDownloadTask <POSHTTPTask>
/// Signal, which emits NSValue with MRCTaskProgress inside.
@property (nonatomic, readonly) RACSignal *downloadProgress;
/// Signal, which emits NSURL with location of downloaded file.
@property (nonatomic, readonly) RACSignal *downloadCompleted;
@end

/// Represents properties of uploading task.
@protocol POSHTTPUploadTask <POSHTTPTask>
/// Signal, which emits NSValue with MRCTaskProgress inside.
@property (nonatomic, readonly) RACSignal *uploadProgress;
@end

/// Performs network requests.
@protocol POSHTTPGateway <POSSchedulable>

/// @brief Performs data request.
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param options Request options.
- (id<POSHTTPTask>)dataTaskWithRequest:(id<POSHTTPRequest>)request
                                toHost:(NSURL *)hostURL
                               options:(POSHTTPRequestExecutionOptions *)options;

/// @brief Performs downloading data from host.
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param options Request options.
- (id<POSHTTPDownloadTask>)downloadTaskWithRequest:(id<POSHTTPRequest>)request
                                            toHost:(NSURL *)hostURL
                                           options:(POSHTTPRequestExecutionOptions *)options;

/// @brief Performs uploading data to host in foreground. Upload will be freezed when app enters backgound.
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param options Request options.
- (id<POSHTTPUploadTask>)uploadTaskWithRequest:(id<POSHTTPUploadRequest>)request
                                        toHost:(NSURL *)hostURL
                                       options:(POSHTTPRequestExecutionOptions *)options;

/// @brief Performs uploading data to host in background.
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param options Request options.
/// @param recoveryContext Data where you can store some state to handle uploading result after app relaunch.
- (id<POSHTTPUploadTask>)backgroundUploadTaskWithRequest:(id<POSHTTPBackgroundUploadRequest>)request
                                                  toHost:(NSURL *)hostURL
                                                 options:(POSHTTPRequestExecutionOptions *)options
                                                userInfo:(id<NSObject,NSCoding>)userInfo;

/// @brief Recovers all background upload tasks as array of id<MRCHTTPUploadTask>.
- (void)recoverBackgroundUploadTasksUsingBlock:(void(^)(NSArray *uploadTasks))block;

/// @brief Performs cleanup logic, which is required to free memory allocated by HTTPGateway.
/// @param cancelPendingTasks YES if you want to free all allocated resources immediatelly.
- (void)invalidateCancelingTasks:(BOOL)cancelPendingTasks;

@end

@interface POSHTTPGateway : POSSchedulableObject <POSHTTPGateway>
/// The designated initializer for launching in a background.
- (instancetype)initWithScheduler:(RACScheduler *)scheduler backgroundSessionIdentifier:(NSString *)ID;
@end
