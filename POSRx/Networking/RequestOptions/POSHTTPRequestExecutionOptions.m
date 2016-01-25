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

+ (instancetype)merge:(POSHTTPRequestExecutionOptions *)source
                 with:(POSHTTPRequestExecutionOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPRequestExecutionOptions alloc]
            initWithHTTPOptions:[POSHTTPRequestOptions merge:source.HTTP with:target.HTTP]
            simulationOptions:(target.simulation ?: source.simulation)];
}

+ (instancetype)merge:(POSHTTPRequestExecutionOptions *)source
      withHTTPOptions:(POSHTTPRequestOptions *)targetHTTP {
    if (!source && !targetHTTP) {
        return nil;
    }
    return [[POSHTTPRequestExecutionOptions alloc]
            initWithHTTPOptions:[POSHTTPRequestOptions merge:source.HTTP with:targetHTTP]
            simulationOptions:source.simulation];
}

+ (instancetype)merge:(POSHTTPRequestExecutionOptions *)source
withSimulationOptions:(POSHTTPRequestSimulationOptions *)targetSimulation {
    if (!source && !targetSimulation) {
        return nil;
    }
    return [[POSHTTPRequestExecutionOptions alloc]
            initWithHTTPOptions:[source.HTTP copy]
            simulationOptions:(targetSimulation ?: source.simulation)];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone]
            initWithHTTPOptions:[_HTTP copy]
            simulationOptions:[_simulation copy]];
}

@end
