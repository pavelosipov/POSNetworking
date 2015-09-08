//
//  POSHTTPRequestSimulationOptions.h
//  POSRx
//
//  Created by Osipov on 07.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POSHTTPResponse;

/// Options to simulate responses from server.
@interface POSHTTPRequestSimulationOptions : NSObject <NSCopying, NSCoding>

/// Value in [0..1] range which spicifies probability of the falure simulation.
/// Default value is 0.05f.
/// @remarks Value 0.0f means that simulation is off.
/// @remarks Value 1.0f means that all responses will be simulated.
@property (nonatomic, assign) float rate;

/// Specifies probability of the each failure codes using absolute values.
/// Example below shows how to simulate aprox. one 403 response for
/// each twenty 500 responses.
/// @code
/// POSHTTPRequestExecutionOptions *options = [POSHTTPRequestExecutionOptions new];
/// options.simulation.rate = 0.07f;
/// options.simulation.self.responses = @{
///     [[POSHTTPResponse alloc] initWithStatusCode:403]: @(1),
///     [[POSHTTPResponse alloc] initWithStatusCode:500]: @(20)
/// };
@property (nonatomic, copy) NSDictionary *responses;

/// @brief Probe simulation.
/// @return Response if it is time to simulate according to 'rate' parameter
///         or nil in other case.
- (POSHTTPResponse *)probeSimulationWithURL:(NSURL *)URL;

@end
