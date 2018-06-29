//
//  POSHTTPRequestOptions.h
//  POSNetworking
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@class POSHTTPRequestPacketOptions;
@class POSHTTPRequestSimulationOptions;

///
/// Options to configure different aspects of HTTP request execution.
///
@interface POSHTTPRequestOptions : NSObject

/// HTTP related parameters.
@property (nonatomic, readonly, nullable) POSHTTPRequestPacketOptions *packet;

/// Options to simulate responses from server.
@property (nonatomic, readonly, nullable) POSHTTPRequestSimulationOptions *simulation;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
                          with:(nullable POSHTTPRequestOptions *)target;

/// @return New instance of options where input packet options added to target
///         packet options. Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
             withPacketOptions:(nullable POSHTTPRequestPacketOptions *)target;

/// @return New instance of options where input simulation options replace
///         target simulation options. Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
         withSimulationOptions:(nullable POSHTTPRequestSimulationOptions *)target;

/// The designated initializer.
- (instancetype)initWithPacketOptions:(nullable POSHTTPRequestPacketOptions *)packet
                    simulationOptions:(nullable POSHTTPRequestSimulationOptions *)simulation;

POS_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
