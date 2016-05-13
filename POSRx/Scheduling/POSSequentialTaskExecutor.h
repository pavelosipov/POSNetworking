//
//  POSSequentialTaskExecutor.h
//  POSRx
//
//  Created by Osipov on 10/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSTask.h"
#import "POSTaskQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSSequentialTaskExecutor : POSSchedulableObject <POSTaskExecutor>

@property (nonatomic) NSInteger maxConcurrentTaskCount;

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                        taskQueue:(id<POSTaskQueue>)taskQueue;

- (instancetype)initWithUnderlyingExecutor:(id<POSTaskExecutor>)executor
                                 taskQueue:(id<POSTaskQueue>)taskQueue;

/// Hiding deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
