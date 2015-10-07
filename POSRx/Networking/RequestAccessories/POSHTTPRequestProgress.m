//
//  POSHTTPRequestProgress.m
//  POSRx
//
//  Created by Pavel Osipov on 18.07.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestProgress.h"

@implementation POSHTTPRequestProgress

- (instancetype)initWithReadyUnits:(uint64_t)readyUnits totalUnits:(uint64_t)totalUnits {
    if (self = [super init]) {
        _readyUnits = readyUnits;
        _totalUnits = totalUnits;
    }
    return self;
}

@end
