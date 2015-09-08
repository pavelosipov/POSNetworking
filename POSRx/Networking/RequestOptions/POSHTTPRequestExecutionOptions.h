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
@property (nonatomic) POSHTTPRequestOptions *HTTP;

/// Options to simulate responses from server.
@property (nonatomic) POSHTTPRequestSimulationOptions *simulation;

/// @return New instance of options where input options override target options.
///         Nil options will not override not nil options.
- (instancetype)merge:(POSHTTPRequestExecutionOptions *)options;

@end
