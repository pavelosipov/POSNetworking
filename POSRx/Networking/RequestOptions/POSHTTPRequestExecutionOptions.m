//
//  POSHTTPRequestExecutionOptions.m
//  POSRx
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestExecutionOptions.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPRequestSimulationOptions.h"

@implementation POSHTTPRequestExecutionOptions

#pragma mark Lifecycle

- (instancetype)initWithHTTPOptions:(POSHTTPRequestOptions *)HTTP
                  simulationOptions:(POSHTTPRequestSimulationOptions *)simulation {
    if (self = [super init]) {
        _HTTP = HTTP;
        _simulation = simulation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _HTTP = [aDecoder decodeObjectForKey:@"HTTP"];
        _simulation = [aDecoder decodeObjectForKey:@"simulation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_HTTP) {
        [aCoder encodeObject:_HTTP forKey:@"HTTP"];
    }
    if (_simulation) {
        [aCoder encodeObject:_simulation forKey:@"simulation"];
    }
}

#pragma mark Public

- (instancetype)merge:(POSHTTPRequestExecutionOptions *)options {
    return [self p_mergeHTTP:options.HTTP simulation:options.simulation];
}

- (instancetype)mergeHTTPOptions:(POSHTTPRequestOptions *)options {
    return [self p_mergeHTTP:options simulation:nil];
}

- (instancetype)mergeSimulationOptions:(POSHTTPRequestSimulationOptions *)options {
    return [self p_mergeHTTP:nil simulation:options];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone]
            initWithHTTPOptions:[_HTTP copy]
            simulationOptions:[_simulation copy]];
}

#pragma mark Private

- (instancetype)p_mergeHTTP:(POSHTTPRequestOptions *)HTTP
                 simulation:(POSHTTPRequestSimulationOptions *)simulation {
    POSHTTPRequestOptions *mergedHTTP = _HTTP ? [_HTTP merge:HTTP] : [HTTP copy];
    POSHTTPRequestSimulationOptions *mergedSimulation = simulation ? [simulation copy] : [_simulation copy];
    return [[POSHTTPRequestExecutionOptions alloc]
            initWithHTTPOptions:mergedHTTP
            simulationOptions:mergedSimulation];
}

@end
