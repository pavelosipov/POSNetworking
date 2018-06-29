//
//  POSHTTPRequestSimulationOptions.h
//  POSNetworking
//
//  Created by Pavel Osipov on 07.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPRequest;
@class POSHTTPResponse;

/// Factory block for simulating response for specified request.
typedef POSHTTPResponse * _Nullable (^POSHTTPResponseSimulator)(id<POSHTTPRequest> request);

/// Options to simulate responses from server.
@interface POSHTTPRequestSimulationOptions : NSObject

///
/// @brief   Value in [0..100] range which spicifies probability percent of the falure simulation.
///
/// @remarks Value 0 means that simulation is off.
/// @remarks Value 100 or more means that all responses will be simulated.
///
@property (nonatomic, readonly) NSUInteger rate;

///
/// @brief   Specifies probability of the each failure codes using absolute values.
///          Example below shows how to simulate responses with 403 and 500 status
///          codes with probability 1:20.
///
/// @code
/// [[POSHTTPRequestSimulationOptions alloc]
///  initWithRate:100
///  responseSimulator:^POSHTTPResponse *(id<POSHTTPRequest> request) {
///      uint32_t probe = arc4random() % 20;
///      if (probe < 19) return [[POSHTTPResponse alloc] initWithStatusCode:500];
///      return [[POSHTTPResponse alloc] initWithStatusCode:403];
///  }];
///
@property (nonatomic, readonly, copy) POSHTTPResponseSimulator responseSimulator;

///
/// @brief  Probes simulation.
///
/// @return Response if it is time to simulate according to 'rate' parameter or nil in other case.
///
- (nullable POSHTTPResponse *)probeSimulationForRequest:(id<POSHTTPRequest>)request;

///
/// @brief  The designated initializer
///
/// @param  rate Value in [0..100] range which spicifies probability percent of the falure simulation.
/// @param  responseSimulator Returns approprite response for specified request when its time to do that.
///                           It may return nil to skip simulation.
///
- (instancetype)initWithRate:(NSUInteger)rate
           responseSimulator:(POSHTTPResponse * _Nullable (^)(id<POSHTTPRequest> request))simulator NS_DESIGNATED_INITIALIZER;

POS_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
