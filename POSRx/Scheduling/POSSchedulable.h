//
//  POSSchedulable.h
//  POSRx
//
//  Created by Pavel Osipov on 12.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#   import <ReactiveObjC/ReactiveObjC.h>
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@protocol POSSchedulable <NSObject>

@property (nonatomic, readonly) RACTargetQueueScheduler *scheduler;

/// @return Signal with this nonnull object delivered in the object's scheduler.
- (RACSignal *)schedule;

/// Schedules that object in the object's scheduler.
- (void)scheduleBlock:(void (^)(id schedulable))block;

@end

NS_ASSUME_NONNULL_END
