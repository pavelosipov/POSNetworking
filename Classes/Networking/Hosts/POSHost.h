//
//  MRCHost.h
//  MRCloudSDK
//
//  Created by Pavel Osipov on 22.09.15.
//  Copyright (c) 2015 Mail.Ru Group. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MRCTracker;
@class MRCHostMetadata;

/// Base host implementation.
@protocol MRCHost <POSSchedulable>

/// Host unique identifier.
@property (nonatomic, readonly) NSString *ID;

/// URL of the host. May be nil.
@property (nonatomic, readonly, nullable) NSURL *URL;

/// @return Signal of nonnull NSURL.
- (RACSignal *)fetchURL;

/// @return Signal of nonnull NSURL.
- (RACSignal *)fetchURLWithMethod:(nullable POSHTTPRequestMethod *)method;

/// @brief Sends request.
/// @param request Sending request.
/// @return Signal of response handling result.
- (RACSignal *)pushRequest:(POSHTTPRequest *)request;

/// @brief Sends request.
/// @param request Sending request.
/// @param options Custom options which will override host-specific options.
/// @return Signal of response handling result.
- (RACSignal *)pushRequest:(POSHTTPRequest *)request
                   options:(nullable POSHTTPRequestExecutionOptions *)options;

@end

/// Base implementation for MRCHost protocol.
@interface MRCHost : POSSchedulableObject <MRCHost>

/// @brief The designated initializer.
/// @param ID Host identifier.
/// @param gateway Mandatory gateway.
/// @tracker Optional service for tracking host-specific events.
/// @return Host instance with static URL.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<MRCTracker>)tracker;

/// Hiding deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE;

@end

#pragma mark -

@interface NSError (MRCHost)

@property (nonatomic, readonly, class) NSString *mrc_hostErrorCategory;

+ (NSError *)mrc_hostErrorWithHostID:(NSString *)hostID
                             hostURL:(nullable NSURL *)hostURL
                              reason:(nullable NSError *)reason;

@end

NS_ASSUME_NONNULL_END
