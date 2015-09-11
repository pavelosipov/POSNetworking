//
//  POSHTTPGateway.h
//  POSRx
//
//  Created by Pavel Osipov on 22.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"

#pragma mark - Gateway

@class POSHTTPRequest;
@class POSHTTPRequestExecutionOptions;

/// Performs network requests.
@protocol POSHTTPGateway <POSSchedulable>

/// Session, which manages foreground requests.
@property (nonatomic, readonly) NSURLSession *foregroundSession;

/// Session, which manages background requests.
@property (nonatomic, readonly) NSURLSession *backgroundSession;

/// @brief Sends request to specified host.
/// @param request Request which will be send to host with specified baseURL.
/// @param hostURL URL, which will be combined with request's endpoint method to construct full URL.
/// @param options Request options.
- (RACSignal *)pushRequest:(POSHTTPRequest *)request
                    toHost:(NSURL *)hostURL
                   options:(POSHTTPRequestExecutionOptions *)options;

/// @brief Recovers all background upload requests as array of POSRecoveredHTTPBackgroundUpload objects.
- (void)recoverBackgroundUploadRequestsUsingBlock:(void(^)(NSArray *uploadRequests))block;

/// @brief Invalidates all sessions, which is mandatory requirement to free memory allocated by HTTPGateway.
/// @param cancelPendingRequests YES if you want to free all allocated resources ASAP or NO to complete active requests.
- (RACSignal *)invalidateCancelingRequests:(BOOL)cancelPendingRequests;

@end

/// Performs network requests.
@interface POSHTTPGateway : POSSchedulableObject <POSHTTPGateway>

/// The designated initializer for launching in a background.
- (instancetype)initWithScheduler:(RACScheduler *)scheduler backgroundSessionIdentifier:(NSString *)ID;

@end
