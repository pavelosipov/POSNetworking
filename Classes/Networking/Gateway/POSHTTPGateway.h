//
//  POSHTTPGateway.h
//  POSNetworking
//
//  Created by Pavel Osipov on 22.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSScheduling/POSScheduling.h>

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPRequest;
@protocol POSTask;

@class POSHTTPRequestOptions;

/// Performs network requests.
@protocol POSHTTPGateway <POSSchedulable>

/// Default options for request execution.
@property (nonatomic, nullable) POSHTTPRequestOptions *options;

/// Session, which manages foreground requests.
@property (nonatomic, readonly) NSURLSession *foregroundSession;

/// Session, which manages background requests.
@property (nonatomic, readonly, nullable) NSURLSession *backgroundSession;

///
/// @brief Sends request to specified host.
///
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param options Request execution options.
///
- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                      options:(nullable POSHTTPRequestOptions *)options;

/// @brief Invalidates all sessions, which is mandatory requirement to free memory allocated by HTTPGateway.
/// @param forced YES if you want to free all allocated resources ASAP or NO to wait for completion of active requests.
- (RACSignal *)invalidateForced:(BOOL)forced;

@end

#pragma mark -

/// Performs network requests.
@interface POSHTTPGateway : POSSchedulableObject <POSHTTPGateway>

/// The designated initializer for launching in a background.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
      backgroundSessionIdentifier:(nullable NSString *)ID NS_DESIGNATED_INITIALIZER;

POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
