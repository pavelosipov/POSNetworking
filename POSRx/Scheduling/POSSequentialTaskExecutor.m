//
//  POSSequentialTaskExecutor.m
//  POSRx
//
//  Created by Osipov on 10/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSSequentialTaskExecutor.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSTask (POSConcurrentTaskExecutor)
@property (nonatomic, nullable, setter = posrx_setSubscriber:) id<RACSubscriber> posrx_subscriber;
@property (nonatomic, nullable, setter = posrx_setExecutionDisposable:) RACDisposable *posrx_executionDisposable;
@end

#pragma mark -

@interface POSSequentialTaskExecutor ()
@property (nonatomic, readonly) id<POSTaskExecutor> underlyingExecutor;
@property (nonatomic, readonly) id<POSTaskQueue> pendingTasks;
@property (nonatomic, readonly) NSMutableArray<id<POSTask>> *executingTasks;
@property (nonatomic, nullable) RACDisposable *processingDisposable;
@end

@implementation POSSequentialTaskExecutor

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                        taskQueue:(id<POSTaskQueue>)taskQueue {
    POSRX_CHECK(scheduler);
    POSRX_CHECK(taskQueue);
    return [self initWithUnderlyingExecutor:[[POSDirectTaskExecutor alloc] initWithScheduler:scheduler]
                                  taskQueue:taskQueue];
}

- (instancetype)initWithUnderlyingExecutor:(id<POSTaskExecutor>)executor
                                 taskQueue:(id<POSTaskQueue>)taskQueue {
    POSRX_CHECK(executor);
    POSRX_CHECK(taskQueue);
    if (self = [super initWithScheduler:executor.scheduler]) {
        _underlyingExecutor = executor;
        _pendingTasks = taskQueue;
        _maxConcurrentTaskCount = 1;
        _executingTasks = [NSMutableArray<id<POSTask>> new];
    }
    return self;
}

- (void)dealloc {
    [_processingDisposable dispose];
}

#pragma mark POSTaskExecutor

- (RACSignal *)submitTask:(POSTask *)task {
    POSRX_CHECK(![task isExecuting]);
    RACSignal *executeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        task.posrx_subscriber = subscriber;
        return [RACDisposable disposableWithBlock:^{
            [self p_reclaimTask:task];
        }];
    }];
    [_pendingTasks enqueueTask:task];
    [self p_scheduleProcessPendingTasks];
    return executeSignal;
}

- (void)reclaimTask:(POSTask *)task {
    [self p_reclaimTask:task];
}

#pragma mark Public

- (void)setMaxConcurrentTaskCount:(NSInteger)count {
    if (count > _maxConcurrentTaskCount) {
        [self p_scheduleProcessPendingTasks];
    }
    _maxConcurrentTaskCount = count;
}

#pragma mark Private

- (void)p_reclaimTask:(POSTask *)task {
    if (task.posrx_subscriber) {
        task.posrx_subscriber = nil;
        [_pendingTasks dequeueTask:task];
    } else if (task.posrx_executionDisposable) {
        [task.posrx_executionDisposable dispose];
        [_executingTasks removeObject:task];
        [self p_scheduleProcessPendingTasks];
    }
}

- (void)p_scheduleProcessPendingTasks {
    if (!_processingDisposable) {
        self.processingDisposable = [[self schedule] subscribeNext:^(POSSequentialTaskExecutor *this) {
            if (![this.processingDisposable isDisposed]) {
                [this p_processPendingTasks];
            }
            this.processingDisposable = nil;
        }];
    }
}

- (void)p_processPendingTasks {
    while (_executingTasks.count < _maxConcurrentTaskCount) {
        POSTask *task = [_pendingTasks dequeueTopTask];
        if (!task) {
            break;
        }
        if (task.posrx_executionDisposable) {
            continue;
        }
        [_executingTasks addObject:task];
        id<RACSubscriber> taskSubscriber = task.posrx_subscriber;
        task.posrx_subscriber = nil;
        task.posrx_executionDisposable = [[_underlyingExecutor submitTask:task] subscribeNext:^(id value) {
            [taskSubscriber sendNext:value];
        } error:^(NSError *error) {
            [taskSubscriber sendError:error];
        } completed:^{
            [taskSubscriber sendCompleted];
        }];
    }
}

@end

#pragma mark -

static char kPOSTaskSubscriberKey;
static char kPOSTaskExecutionDisposableKey;

@implementation POSTask (POSConcurrentTaskExecutor)

- (nullable id<RACSubscriber>)posrx_subscriber {
    return objc_getAssociatedObject(self, &kPOSTaskSubscriberKey);
}

- (void)posrx_setSubscriber:(nullable id<RACSubscriber>)subscriber {
    objc_setAssociatedObject(self, &kPOSTaskSubscriberKey, subscriber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable RACDisposable *)posrx_executionDisposable {
    return objc_getAssociatedObject(self, &kPOSTaskExecutionDisposableKey);
}

- (void)posrx_setExecutionDisposable:(nullable RACDisposable *)disposable {
    objc_setAssociatedObject(self, &kPOSTaskExecutionDisposableKey, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
