//
//  POSHTTPRequestOptions.m
//  POSNetworking
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestOptions.h"
#import "POSHTTPRequestPacketOptions.h"
#import "POSHTTPRequestSimulationOptions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPRequestOptions

- (instancetype)initWithPacketOptions:(nullable POSHTTPRequestPacketOptions *)packet
                    simulationOptions:(nullable POSHTTPRequestSimulationOptions *)simulation {
    if (self = [super init]) {
        _packet = packet;
        _simulation = simulation;
    }
    return self;
}

+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
                          with:(nullable POSHTTPRequestOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPRequestOptions alloc]
        initWithPacketOptions:[POSHTTPRequestPacketOptions merge:source.packet with:target.packet]
        simulationOptions:(target.simulation ?: source.simulation)];
}

+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
             withPacketOptions:(nullable POSHTTPRequestPacketOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPRequestOptions alloc]
        initWithPacketOptions:[POSHTTPRequestPacketOptions merge:source.packet with:target]
        simulationOptions:source.simulation];
}

+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
         withSimulationOptions:(nullable POSHTTPRequestSimulationOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPRequestOptions alloc]
        initWithPacketOptions:source.packet
        simulationOptions:(target ?: source.simulation)];
}

@end

NS_ASSUME_NONNULL_END
