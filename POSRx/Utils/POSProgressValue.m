//
//  POSProgressValue.m
//  POSRx
//
//  Created by Pavel Osipov on 18.07.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSProgressValue.h"

@implementation POSProgressValue

- (instancetype)initWithReady:(uint64_t)ready total:(uint64_t)total {
    if (self = [super init]) {
        _ready = ready;
        _total = total;
    }
    return self;
}

@end
