//
//  POSSchedulable.h
//  POSRx
//
//  Created by Pavel Osipov on 12.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol POSSchedulable <NSObject>

@property (nonatomic, readonly) RACTargetQueueScheduler *scheduler;

/// @return Signal with this nonnull object delivered in the object's scheduler.
- (RACSignal *)schedule;

@end

NS_ASSUME_NONNULL_END
