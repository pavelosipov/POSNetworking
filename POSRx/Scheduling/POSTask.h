//
//  POSTask.h
//  POSRx
//
//  Created by Pavel Osipov on 26.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSTaskExecutor;

/// Task represents restartable and cancelable unit of work.
@protocol POSTask <POSSchedulable>

/// Emits YES when task is about to start and NO when task is about to finish.
/// Always emits some value on subscription.
@property (nonatomic, readonly) RACSignal *executing;

/// Emits values from source signal and keeps the last one until reexecution.
@property (nonatomic, readonly) RACSignal *values;

/// Emits errors from source signal and keeps the last one until reexecution.
@property (nonatomic, readonly) RACSignal *errors;

/// @return YES if task is executing right now.
- (BOOL)isExecuting;

/// Launches task directly or schedules it within specified executor.
- (RACSignal *)execute;

/// Interrupts task without emitting errors.
- (void)cancel;

/// Interrupts task and emits error.
- (void)cancelWithError:(NSError *)error;

@end

@interface POSTask : POSSchedulableObject <POSTask>

/// The designated initializer.
- (instancetype)initWithExecutionBlock:(RACSignal *(^)(id task))executionBlock
                             scheduler:(RACTargetQueueScheduler *)scheduler
                              executor:(nullable id<POSTaskExecutor>)executor;

/// Creates self-executable task with implicit UI scheduler.
+ (instancetype)createTask:(RACSignal *(^)(id task))executionBlock;

/// Creates self-executable task.
+ (instancetype)createTask:(RACSignal *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler;

/// Creates task which should be scheduled and executed only within specified executor.
+ (instancetype)createTask:(RACSignal *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler
                  executor:(nullable id<POSTaskExecutor>)executor;

/// Preventing usage of base initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE;

@end

/// Specifies protocol which should be impleme
@protocol POSTaskExecutor <NSObject>

/// @return Signal which will emit emits values about task execution.
- (RACSignal *)pushTask:(POSTask *)task;

@end

/// The minimal implementation of executors which executes task immediately after push.
/// This executor should be used as a base class for more complicated executors.
@interface POSDirectTaskExecutor : NSObject <POSTaskExecutor>
@end

NS_ASSUME_NONNULL_END
