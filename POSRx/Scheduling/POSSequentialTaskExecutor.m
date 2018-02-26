//
//  POSSequentialTaskExecutor.m
//  POSRx
//
//  Created by Pavel Osipov on 10/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSSequentialTaskExecutor.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSTask (POSConcurrentTaskExecutor)
@property (nonatomic, nullable, setter = posrx_setSubscriber:) id<RACSubscriber> posrx_subscriber;
@property (nonatomic, nullable, setter = posrx_setReclaimDisposable:) RACDisposable *posrx_reclaimDisposable;
@end

#pragma mark -

@interface POSSequentialTaskExecutor ()
@property (nonatomic, readonly) id<POSTaskExecutor> underlyingExecutor;
@property (nonatomic, readonly) id<POSTaskQueue> pendingTasks;
@property (nonatomic, readonly) NSMutableArray<id<POSTask>> *mutableExecutingTasks;
@property (nonatomic, readonly) RACSubject *executingTasksCountSubject;
@end

@implementation POSSequentialTaskExecutor

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                          options:(nullable POSScheduleProtectionOptions *)options {
    typedef NSMutableArray<POSTask *> Queue_t;
    return [self
            initWithUnderlyingExecutor:[[POSDirectTaskExecutor alloc] initWithScheduler:scheduler]
            taskQueue:
            [[POSTaskQueueAdapter<Queue_t *> alloc]
             initWithScheduler:scheduler
             container:[Queue_t new]
             dequeueTopTaskBlock:^POSTask *(Queue_t *queue) {
                 POSTask *task = queue.firstObject;
                 [queue removeObject:task];
                 return task;
             } dequeueTaskBlock:^(Queue_t *queue, POSTask *task) {
                 [queue removeObject:task];
             } enqueueTaskBlock:^(Queue_t *queue, POSTask *task) {
                 [queue addObject:task];
             }]
            options:options];
}

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                        taskQueue:(id<POSTaskQueue>)taskQueue {
    POSRX_CHECK(scheduler);
    POSRX_CHECK(taskQueue);
    return [self initWithUnderlyingExecutor:[[POSDirectTaskExecutor alloc] initWithScheduler:scheduler]
                                  taskQueue:taskQueue];
}

- (instancetype)initWithUnderlyingExecutor:(id<POSTaskExecutor>)executor
                                 taskQueue:(id<POSTaskQueue>)taskQueue {
    return [self initWithUnderlyingExecutor:executor taskQueue:taskQueue options:nil];
}

- (instancetype)initWithUnderlyingExecutor:(id<POSTaskExecutor>)executor
                                 taskQueue:(id<POSTaskQueue>)taskQueue
                                   options:(nullable POSScheduleProtectionOptions *)options {
    POSRX_CHECK(executor);
    POSRX_CHECK(taskQueue);
    if (self = [super initWithScheduler:executor.scheduler options:options]) {
        _executingTasksCountSubject = [RACSubject subject];
        _underlyingExecutor = executor;
        _pendingTasks = taskQueue;
        _maxExecutingTasksCount = 1;
        _mutableExecutingTasks = [NSMutableArray array];
    }
    return self;
}

#pragma mark POSTaskExecutor

- (RACSignal *)submitTask:(POSTask *)task {
    POSRX_CHECK(![task isExecuting]);
    POSRX_CHECK(task.posrx_reclaimDisposable == nil);
    RACSignal *executeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        task.posrx_subscriber = subscriber;
        return [RACDisposable disposableWithBlock:^{
            [task.posrx_reclaimDisposable dispose];
        }];
    }];
    [_pendingTasks enqueueTask:task];
    @weakify(self);
    @weakify(task);
    task.posrx_reclaimDisposable = [RACDisposable disposableWithBlock:^{
        @strongify(self);
        @strongify(task);
        task.posrx_reclaimDisposable = nil;
        task.posrx_subscriber = nil;
        [self.pendingTasks dequeueTask:task];
    }];
    [self p_scheduleProcessPendingTasks];
    return executeSignal;
}

- (void)reclaimTask:(POSTask *)task {
    [task.posrx_reclaimDisposable dispose];
}

#pragma mark Public

- (void)setMaxExecutingTasksCount:(NSInteger)count {
    if (count > _maxExecutingTasksCount) {
        [self p_scheduleProcessPendingTasks];
    }
    _maxExecutingTasksCount = count;
}

- (NSArray *)executingTasks {
    return [_mutableExecutingTasks copy];
}


- (NSUInteger)executingTasksCount {
    return [_mutableExecutingTasks count];
}

- (RACSignal *)executingTasksCountSignal {
    return [_executingTasksCountSubject takeUntil:self.rac_willDeallocSignal];
}

- (void)executePendingTasks {
    while (_mutableExecutingTasks.count < _maxExecutingTasksCount) {
        POSTask *task = [_pendingTasks dequeueTopTask];
        if (!task) {
            break;
        }
        [self p_addExecutingTask:task];
        id<RACSubscriber> taskSubscriber = task.posrx_subscriber;
        task.posrx_subscriber = nil;
        @weakify(self);
        @weakify(task);
        RACCompoundDisposable *reclaimDisposable = [RACCompoundDisposable compoundDisposable];
        RACDisposable *executeDisposable =
        [[[_underlyingExecutor submitTask:task]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id value) {
             [taskSubscriber sendNext:value];
         } error:^(NSError *error) {
             @strongify(task);
             [task.posrx_reclaimDisposable dispose];
             [taskSubscriber sendError:error];
         } completed:^{
             @strongify(task);
             [task.posrx_reclaimDisposable dispose];
             [taskSubscriber sendCompleted];
         }];
        [reclaimDisposable addDisposable:executeDisposable];
        [reclaimDisposable addDisposable:[RACDisposable disposableWithBlock:^{
            @strongify(self);
            @strongify(task);
            task.posrx_reclaimDisposable = nil;
            [self p_removeExecutingTask:task];
            [self.underlyingExecutor reclaimTask:task];
            [self p_scheduleProcessPendingTasks];
        }]];
        task.posrx_reclaimDisposable = reclaimDisposable;
    }
}

#pragma mark Private

- (void)p_reclaimTask:(POSTask *)task {
    [task.posrx_reclaimDisposable dispose];
}

- (void)p_scheduleProcessPendingTasks {
    [[self schedule] subscribeNext:^(POSSequentialTaskExecutor *this) {
        [this executePendingTasks];
    }];
}

- (void)p_addExecutingTask:(id<POSTask>)task {
    [_mutableExecutingTasks addObject:task];
    [_executingTasksCountSubject sendNext:@(_mutableExecutingTasks.count)];
}

- (void)p_removeExecutingTask:(id<POSTask>)task {
    [_mutableExecutingTasks removeObject:task];
    [_executingTasksCountSubject sendNext:@(_mutableExecutingTasks.count)];
}

@end

#pragma mark -

static char kPOSTaskSubscriberKey;
static char kPOSTaskReclaimDisposableKey;

@implementation POSTask (POSConcurrentTaskExecutor)

- (nullable id<RACSubscriber>)posrx_subscriber {
    return objc_getAssociatedObject(self, &kPOSTaskSubscriberKey);
}

- (void)posrx_setSubscriber:(nullable id<RACSubscriber>)subscriber {
    objc_setAssociatedObject(self, &kPOSTaskSubscriberKey, subscriber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable RACDisposable *)posrx_reclaimDisposable {
    return objc_getAssociatedObject(self, &kPOSTaskReclaimDisposableKey);
}

- (void)posrx_setReclaimDisposable:(nullable RACDisposable *)disposable {
    objc_setAssociatedObject(self, &kPOSTaskReclaimDisposableKey, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
