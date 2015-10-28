//
//  POSHTTPRequestExecutionOptions.h
//  POSRx
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POSHTTPRequestOptions;
@class POSHTTPRequestSimulationOptions;

/// Options to configure executing and handling HTTP request.
@interface POSHTTPRequestExecutionOptions : NSObject <NSCopying, NSCoding>

/// HTTP related parameters.
@property (nonatomic, readonly) POSHTTPRequestOptions *HTTP;

/// Options to simulate responses from server.
@property (nonatomic, readonly) POSHTTPRequestSimulationOptions *simulation;

/// The designated initializer.
- (instancetype)initWithHTTPOptions:(POSHTTPRequestOptions *)HTTP
                  simulationOptions:(POSHTTPRequestSimulationOptions *)simulation;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (instancetype)merge:(POSHTTPRequestExecutionOptions *)source
                 with:(POSHTTPRequestExecutionOptions *)target;

/// @return New instance of options where input HTTP options added to target
///         HTTP options. Nil options will not override not nil options.
+ (instancetype)merge:(POSHTTPRequestExecutionOptions *)source
      withHTTPOptions:(POSHTTPRequestOptions *)targetHTTP;

/// @return New instance of options where input simulation options replace
///         target simulation options. Nil options will not override not nil options.
+ (instancetype)merge:(POSHTTPRequestExecutionOptions *)source
withSimulationOptions:(POSHTTPRequestSimulationOptions *)targetSimulation;

@end
