//
//  POSHost.h
//  POSNetworking
//
//  Created by Pavel Osipov on 22.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSScheduling/POSScheduling.h>

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPGateway;
@protocol POSHTTPRequest;

@class POSHTTPGatewayOptions;
@class POSHTTPRequestOptions;

@interface POSHostURLInfo : NSObject

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly, nullable) POSHTTPRequestOptions *options;

- (instancetype)initWithURL:(NSURL *)URL options:(nullable POSHTTPRequestOptions *)options;

POS_INIT_UNAVAILABLE

@end

/// Base host implementation.
@protocol POSHost <POSSchedulable>

/// URL of the host. May be nil.
@property (nonatomic, readonly, nullable) NSURL *URL;

/// Shared options for all requests performing by that host.
@property (nonatomic, readonly, nullable) POSHTTPGatewayOptions *options;

/// Provides possibility to fetch NSURL if corresponding URL property is nil.
- (RACSignal<POSHostURLInfo *> *)fetchURLInfo;

/// @brief Sends request.
/// @param request Sending request.
/// @return Signal of response handling result.
- (RACSignal<id> *)pushRequest:(id<POSHTTPRequest>)request;

/// @brief Sends request.
/// @param request Sending request.
/// @param options Custom options which will override host-specific options.
/// @return Signal of response handling result.
- (RACSignal<id> *)pushRequest:(id<POSHTTPRequest>)request
                       options:(nullable POSHTTPGatewayOptions *)options;

@end

#pragma mark -

/// Base implementation for POSHost protocol.
@interface POSHost : POSSchedulableObject <POSHost>

- (instancetype)initWithGateway:(id<POSHTTPGateway>)gateway
                        options:(nullable POSHTTPGatewayOptions *)options NS_DESIGNATED_INITIALIZER;

POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
