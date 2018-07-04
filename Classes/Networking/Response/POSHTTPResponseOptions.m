//
//  POSHTTPResponseOptions.m
//  POSNetworking
//
//  Created by Pavel Osipov on 07.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPResponseOptions.h"
#import "POSHTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPResponseOptions

- (instancetype)initWithRate:(NSUInteger)rate responseSimulator:(POSHTTPResponseSimulator)responseSimulator {
    POS_CHECK(responseSimulator);
    if (self = [super init]) {
        _rate = rate;
        _responseSimulator = [responseSimulator copy];
    }
    return self;
}

- (nullable POSHTTPResponse *)probeSimulationForRequest:(id<POSHTTPRequest>)request
                                                hostURL:(NSURL *)hostURL
                                                options:(nullable POSHTTPRequestOptions *)options {
    POS_CHECK(request);
    if ((arc4random() % 100) > _rate) {
        return nil;
    }
    return _responseSimulator(request, hostURL, options);
}

@end

NS_ASSUME_NONNULL_END
