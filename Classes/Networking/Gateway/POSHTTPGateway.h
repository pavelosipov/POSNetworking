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

@class POSHTTPGatewayOptions;

/// Performs network requests.
@protocol POSHTTPGateway <POSSchedulable>

@property (nonatomic, nullable) POSHTTPGatewayOptions *options;
@property (nonatomic, readonly) NSURLSession *foregroundSession;
@property (nonatomic, readonly, nullable) NSURLSession *backgroundSession;

///
/// @brief Sends request to specified host.
///
/// @remarks Options priority chain: (low) gateway <- host <- request <- extra (high)
///
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param hostOptions Host options.
/// @param extraOptions Options with the highest priority.
///
- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                  hostOptions:(nullable POSHTTPGatewayOptions *)hostOptions
                 extraOptions:(nullable POSHTTPGatewayOptions *)extraOptions;

/// @brief Invalidates all sessions, which is mandatory requirement to free memory allocated by HTTPGateway.
/// @param forced YES if you want to free all allocated resources ASAP or NO to wait for completion of active requests.
- (RACSignal *)invalidateForced:(BOOL)forced;

/// Cancels all background tasks.
- (void)invalidateBackgroundTasksWithCompletionHandler:(dispatch_block_t)completionHandler;

@end

#pragma mark -

/// Performs network requests.
@interface POSHTTPGateway : POSSchedulableObject <POSHTTPGateway>

/// The designated initializer for launching in a background.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
      backgroundSessionIdentifier:(nullable NSString *)ID
                          options:(nullable POSHTTPGatewayOptions *)options NS_DESIGNATED_INITIALIZER;

POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
