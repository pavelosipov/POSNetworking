//
//  POSTask.h
//  POSRx
//
//  Created by Pavel Osipov on 26.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"

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

/// Additional task signals.
 - (RACSignal *)signalForEvent:(id)eventKey;

/// Launches task directly or schedules it within specified executor.
- (void)execute;

/// Interrupts task without emitting errors.
- (void)cancel;

/// Interrupts task and emits error.
- (void)cancelWithError:(NSError *)error;

@end

/// Context contains state which is shared between executions.
@interface POSTaskContext : NSObject

/// Subjects for emitting additional events during execution.
- (RACSubject *)subjectForEvent:(id)eventKey;

@end

@interface POSTask : POSSchedulableObject <POSTask>

/// Creates self-executable task with implicit UI scheduler.
+ (instancetype)createTask:(RACSignal *(^)(POSTaskContext *context))executionBlock;

/// Creates self-executable task.
+ (instancetype)createTask:(RACSignal *(^)(POSTaskContext *context))executionBlock
                 scheduler:(RACScheduler *)scheduler;

/// Creates task which should be scheduled and executed only within specified executor.
+ (instancetype)createTask:(RACSignal *(^)(POSTaskContext *context))executionBlock
                 scheduler:(RACScheduler *)scheduler
                  executor:(id<POSTaskExecutor>)executor;

@end

/// Specifies protocol which should be impleme
@protocol POSTaskExecutor <NSObject>

- (void)pushTask:(POSTask *)task;

@end

/// The minimal implementation of executors which executes task immediately after push.
/// This executor should be used as a base class for more complicated executors.
@interface POSDirectTaskExecutor : NSObject <POSTaskExecutor>
@end
