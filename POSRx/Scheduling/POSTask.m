//
//  POSTask.m
//  POSRx
//
//  Created by Pavel Osipov on 26.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSTask.h"
#import "NSException+POSRx.h"
#import "RACTargetQueueScheduler+POSRx.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSTask ()
@property (nonatomic, copy, readonly) RACSignal *(^executionBlock)(POSTask *task);
@property (nonatomic, weak) id<POSTaskExecutor> executor;
@property (nonatomic) RACSignal *executing;
@property (nonatomic) RACSignal *sourceSignals;
@property (nonatomic, nullable) RACSignal *sourceSignal;
@property (nonatomic, nullable) RACDisposable *sourceSignalDisposable;
@property (nonatomic) RACSignal *errors;
@property (nonatomic) RACSubject *extraErrors;
@property (nonatomic) RACSignal *values;
@end

@implementation POSTask

#pragma mark Lifecycle

- (instancetype)initWithExecutionBlock:(RACSignal *(^)(id))executionBlock
                             scheduler:(RACTargetQueueScheduler *)scheduler
                              executor:(nullable id<POSTaskExecutor>)executor {
    POSRX_CHECK(scheduler);
    POSRX_CHECK(executionBlock);
    if (self = [super initWithScheduler:scheduler]) {
        _executionBlock = [executionBlock copy];
        _executor = executor;
        
        _sourceSignals = RACObserve(self, sourceSignal);

        _executing = [[[_sourceSignals map:^(RACSignal *signal) {
            return @(signal != nil);
        }] distinctUntilChanged] replayLast];
        
        _values = [[[_sourceSignals map:^id(RACSignal *signal) {
            return [signal catchTo:[RACSignal empty]];
        }] replayLast] switchToLatest];

        _extraErrors = [RACSubject subject];
        RACSignal *executionErrors = [[[_sourceSignals map:^id(RACSignal *signal) {
            return [[signal ignoreValues] catch:^(NSError *error) {
                return [RACSignal return:error];
            }];
        }] replayLast] switchToLatest];
        _errors = [[RACSignal
                    merge:@[_extraErrors, executionErrors]]
                    takeUntil:[self rac_willDeallocSignal]];
    }
    return self;
}

+ (instancetype)createTask:(RACSignal *(^)(id task))executionBlock {
    return [self createTask:executionBlock scheduler:nil executor:nil];
}

+ (instancetype)createTask:(RACSignal *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler {
    return [self createTask:executionBlock scheduler:scheduler executor:nil];
}

+ (instancetype)createTask:(RACSignal *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler
                  executor:(nullable id<POSTaskExecutor>)executor {
    return [[self alloc] initWithExecutionBlock:executionBlock
                                      scheduler:(scheduler ?: [RACTargetQueueScheduler pos_mainThreadScheduler])
                                       executor:executor];
}

#pragma mark POSTask

- (BOOL)isExecuting {
    return _sourceSignal != nil;
}

- (RACSignal *)execute {
    if (_executor) {
        return [_executor submitTask:self];
    } else {
        return [self p_executeWithDisposableBlock:^{
            [self p_cancelNow];
        }];
    }
}

- (void)cancel {
    if (_executor) {
        [_executor reclaimTask:self];
    } else {
        [self p_cancelNow];
    }
}

- (void)cancelWithError:(NSError *)error {
    [_extraErrors sendNext:error];
    [self cancel];
}

#pragma mark Private

- (RACSignal *)p_executeWithDisposableBlock:(void (^)(void))block {
    NSParameterAssert(![self isExecuting]);
    if ([self isExecuting]) {
        return _sourceSignal;
    }
    RACSignal *signal = self.executionBlock(self);
    POSRX_CHECK(signal);
    RACMulticastConnection *connection = [[signal
        subscribeOn:self.scheduler]
        multicast:RACReplaySubject.subject];
    RACSignal *sourceSignal = [[connection.signal deliverOn:self.scheduler]
                               takeUntil:self.rac_willDeallocSignal];
    self.sourceSignal = sourceSignal;
    @weakify(self);
    [self.sourceSignal subscribeError:^(NSError *error) {
        @strongify(self);
        self.sourceSignal = nil;
    } completed:^{
        @strongify(self);
        self.sourceSignal = nil;
    }];
    self.sourceSignalDisposable = [connection connect];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [sourceSignal subscribe:subscriber];
        return [RACDisposable disposableWithBlock:block];
    }];
}

- (void)p_cancelNow {
    if ([self isExecuting]) {
        [_sourceSignalDisposable dispose];
        self.sourceSignalDisposable = nil;
        self.sourceSignal = nil;
    }
}

@end

#pragma mark - POSDirectTaskExecutor

@implementation POSDirectTaskExecutor

- (RACSignal *)submitTask:(POSTask *)task {
    @weakify(self);
    @weakify(task);
    return [task p_executeWithDisposableBlock:^{
        @strongify(self);
        @strongify(task);
        [self reclaimTask:task];
    }];
}

- (void)reclaimTask:(POSTask *)task {
    [task p_cancelNow];
}

@end

NS_ASSUME_NONNULL_END
