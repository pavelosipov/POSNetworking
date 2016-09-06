//
//  POSProgressValue.m
//  POSRx
//
//  Created by Pavel Osipov on 18.07.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSProgressValue.h"

NS_ASSUME_NONNULL_BEGIN

uint64_t const kPOSProgressValueUnknown = UINT64_MAX;

@implementation POSProgressValue

- (instancetype)initWithReady:(uint64_t)ready total:(uint64_t)total {
    if (self = [super init]) {
        _ready = ready;
        _total = total;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
