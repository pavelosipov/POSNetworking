//
//  POSHTTPGatewayOptions.h
//  POSNetworking
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@class POSHTTPRequestOptions;
@class POSHTTPResponseOptions;

///
/// Options to configure different aspects of HTTP request execution.
///
@interface POSHTTPGatewayOptions : NSObject

/// HTTP related parameters.
@property (nonatomic, readonly, nullable) POSHTTPRequestOptions *requestOptions;

/// Options to simulate responses from server.
@property (nonatomic, readonly, nullable) POSHTTPResponseOptions *responseOptions;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPGatewayOptions *)source
                          with:(nullable POSHTTPGatewayOptions *)target;

/// @return New instance of options where input packet options added to target
///         packet options. Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPGatewayOptions *)source
            withRequestOptions:(nullable POSHTTPRequestOptions *)target;

/// @return New instance of options where input simulation options replace
///         target simulation options. Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPGatewayOptions *)source
           withResponseOptions:(nullable POSHTTPResponseOptions *)target;

/// The designated initializer.
- (instancetype)initWithRequestOptions:(nullable POSHTTPRequestOptions *)requestOptions
                       responseOptions:(nullable POSHTTPResponseOptions *)responseOptions;

POS_INIT_UNAVAILABLE

@end

#pragma mark -

@interface POSHTTPGatewayOptionsBuilder : NSObject

- (POSHTTPGatewayOptions *)build;

- (instancetype)withRequestOptions:(nullable POSHTTPRequestOptions *)requestOptions;
- (instancetype)withResponseOptions:(nullable POSHTTPResponseOptions *)responseOptions;

@end

NS_ASSUME_NONNULL_END
