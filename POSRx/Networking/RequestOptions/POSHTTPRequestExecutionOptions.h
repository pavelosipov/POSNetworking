//
//  POSHTTPRequestExecutionOptions.h
//  POSRx
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POSHTTPRequestOptions;
@class POSHTTPRequestSimulationOptions;

/// Options to configure executing and handling HTTP request.
@interface POSHTTPRequestExecutionOptions : NSObject <NSCopying, NSCoding>

/// HTTP related parameters.
@property (nonatomic, readonly, nullable) POSHTTPRequestOptions *HTTP;

/// Options to simulate responses from server.
@property (nonatomic, readonly, nullable) POSHTTPRequestSimulationOptions *simulation;

/// The designated initializer.
- (instancetype)initWithHTTPOptions:(nullable POSHTTPRequestOptions *)HTTP
                  simulationOptions:(nullable POSHTTPRequestSimulationOptions *)simulation;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestExecutionOptions *)source
                          with:(nullable POSHTTPRequestExecutionOptions *)target;

/// @return New instance of options where input HTTP options added to target
///         HTTP options. Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestExecutionOptions *)source
               withHTTPOptions:(nullable POSHTTPRequestOptions *)targetHTTP;

/// @return New instance of options where input simulation options replace
///         target simulation options. Nil options will not override not nil options.
+ (nullable instancetype)merge:(POSHTTPRequestExecutionOptions *)source
         withSimulationOptions:(POSHTTPRequestSimulationOptions *)targetSimulation;

@end

NS_ASSUME_NONNULL_END
