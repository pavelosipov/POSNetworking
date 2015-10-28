//
//  POSHTTPRequestSimulationOptions.m
//  POSRx
//
//  Created by Osipov on 07.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestSimulationOptions.h"
#import "POSHTTPResponse.h"
#import "NSException+POSRx.h"

@interface POSHTTPRequestSimulation : NSObject <NSCoding>
@property (nonatomic) NSInteger weight;
@property (nonatomic) POSHTTPResponse *response;
@end

@implementation POSHTTPRequestSimulation

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _weight = [[aDecoder decodeObjectForKey:@"weight"] integerValue];
        _response = [aDecoder decodeObjectForKey:@"response"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_weight) forKey:@"weight"];
    [aCoder encodeObject:_response forKey:@"response"];
}

@end

#pragma mark -

@interface POSHTTPRequestSimulationOptions ()
@property (nonatomic) NSArray *simulations;
@end

@implementation POSHTTPRequestSimulationOptions
@dynamic responses;

#pragma mark Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _rate = 0.0f;
        self.responses = [NSDictionary new];
    }
    return self;
}

- (instancetype)initWithRate:(float)rate responses:(NSDictionary *)responses {
    if (self = [super init]) {
        _rate = rate;
        self.responses = responses ?: [NSDictionary new];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _simulations = [aDecoder decodeObjectForKey:@"simulations"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_simulations) {
        [aCoder encodeObject:_simulations forKey:@"simulations"];
    }
}

#pragma mark Public

- (POSHTTPResponse *)probeSimulationWithURL:(NSURL *)URL {
    POSRX_CHECK(URL);
    if (_simulations.count == 0) {
        return nil;
    }
    if (!(((arc4random() % 1000) / 1000.f) < _rate)) {
        return nil;
    }
    NSInteger targetWeight = arc4random() % [_simulations.lastObject weight];
    __block POSHTTPResponse *targetResponse;
    [_simulations enumerateObjectsUsingBlock:^(POSHTTPRequestSimulation *simulation, NSUInteger i, BOOL *stop) {
        targetResponse = simulation.response;
        *stop = (simulation.weight > targetWeight);
    }];
    NSHTTPURLResponse *metadata = [[NSHTTPURLResponse alloc]
                                   initWithURL:URL
                                   statusCode:targetResponse.metadata.statusCode
                                   HTTPVersion:@"1.1"
                                   headerFields:targetResponse.metadata.allHeaderFields];
    return [[POSHTTPResponse alloc] initWithData:targetResponse.data metadata:metadata];
}

- (NSDictionary *)responses {
    NSMutableDictionary *responses = [[NSMutableDictionary alloc] initWithCapacity:_simulations.count];
    __block NSInteger previousWeight = 0;
    [_simulations enumerateObjectsUsingBlock:^(POSHTTPRequestSimulation *simulation, NSUInteger idx, BOOL *stop) {
        responses[simulation.response] = @(simulation.weight - previousWeight);
        previousWeight += simulation.weight;
    }];
    return [responses copy];
}

- (void)setResponses:(NSDictionary *)responses {
    NSMutableArray *simulations = [[NSMutableArray alloc] initWithCapacity:responses.count];
    __block NSInteger rangeBound = 0;
    [responses enumerateKeysAndObjectsUsingBlock:^(POSHTTPResponse *response, NSNumber *weight, BOOL *stop) {
        rangeBound += [weight integerValue];
        POSHTTPRequestSimulation *simulation = [POSHTTPRequestSimulation new];
        simulation.weight = rangeBound;
        simulation.response = response;
        [simulations addObject:simulation];
    }];
    _simulations = simulations;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) clone = [[[self class] allocWithZone:zone] init];
    clone.simulations = [_simulations copy];
    return clone;
}

@end
