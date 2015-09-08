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
    POSHTTPRequestExecutionOptions *mergedOptions = [self copy];
    if (options.HTTP) {
        [mergedOptions.HTTP merge:options.HTTP];
    }
    if (options.simulation) {
        mergedOptions.simulation = options.simulation;
    }
    return mergedOptions;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) clone = [[[self class] allocWithZone:zone] init];
    clone.simulation = [self.simulation copy];
    clone.HTTP = [self.HTTP copy];
    return clone;
}

@end
