//
//  POSProgressValue.h
//  POSRx
//
//  Created by Pavel Osipov on 18.07.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN uint64_t const POSUnknownValue;

@interface POSProgressValue : NSObject

@property (nonatomic, readonly) uint64_t ready;
@property (nonatomic, readonly) uint64_t total;

- (instancetype)initWithReady:(uint64_t)ready
                        total:(uint64_t)total;

@end

NS_ASSUME_NONNULL_END
