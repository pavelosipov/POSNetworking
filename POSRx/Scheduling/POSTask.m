//
//  POSTask.m
//  POSRx
//
//  Created by Pavel Osipov on 26.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSTask.h"
#import "NSException+POSRx.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#pragma mark - POSTaskContext

@interface POSTaskContext ()
@property (nonatomic) NSMutableDictionary *subjects;
@end

@implementation POSTaskContext

- (instancetype)init {
    if (self = [super init]) {
        _subjects = NSMutableDictionary.new;
    }
    return self;
}

- (RACSubject *)subjectForEvent:(id)eventKey {
    RACSubject *subject = _subjects[eventKey];
    if (subject) {
        return subject;
    }
    subject = [RACSubject subject];
    _subjects[eventKey] = subject;
    return subject;
}

@end

#pragma mark - POSTask

@interface POSTask ()
@property (nonatomic, copy, readonly) RACSignal *(^executionBlock)(POSTaskContext *context);
@property (nonatomic, weak) id<POSTaskExecutor> executor;
@property (nonatomic) RACSignal *executing;
@property (nonatomic) RACSignal *sourceSignals;
@property (nonatomic) RACSignal *sourceSignal;
@property (nonatomic) RACDisposable *sourceSignalDisposable;
@property (nonatomic) RACSignal *errors;
@property (nonatomic) RACSubject *extraErrors;
@property (nonatomic) RACSignal *values;
@property (nonatomic) POSTaskContext *context;
@end

@implementation POSTask

#pragma mark - Lifecycle

POSRX_DEADLY_INITIALIZER(init)

- (instancetype)initWithTask:(RACSignal *(^)(POSTaskContext *context))executionBlock
                   scheduler:(RACScheduler *)scheduler
                    executor:(id<POSTaskExecutor>)executor {
    POSRX_CHECK(executionBlock);
    if (self = [super initWithScheduler:scheduler]) {
        _executionBlock = [executionBlock copy];
        _executor = executor;
        _context = POSTaskContext.new;
        
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

+ (instancetype)createTask:(RACSignal *(^)(POSTaskContext *context))executionBlock {
    return [[self.class alloc] initWithTask:executionBlock
                                  scheduler:RACScheduler.mainThreadScheduler
                                   executor:nil];
}

+ (instancetype)createTask:(RACSignal *(^)(POSTaskContext *context))executionBlock
                 scheduler:(RACScheduler *)scheduler {
    return [[self.class alloc] initWithTask:executionBlock
                                  scheduler:scheduler
                                   executor:nil];
}

+ (instancetype)createTask:(RACSignal *(^)(POSTaskContext *))executionBlock
                 scheduler:(RACScheduler *)scheduler
                  executor:(id<POSTaskExecutor>)executor {
    return [[self.class alloc] initWithTask:executionBlock
                                  scheduler:scheduler
                                   executor:executor];
}

#pragma mark - POSTask

- (RACSignal *)signalForEvent:(id)eventKey {
    return [_context subjectForEvent:eventKey];
}

- (BOOL)isExecuting {
    return _sourceSignal != nil;
}

- (RACSignal *)execute {
    if (_executor) {
        return [_executor pushTask:self];
    } else {
        return [self p_executeNow];
    }
}

- (void)cancel {
    if ([self isExecuting]) {
        [_sourceSignalDisposable dispose];
        self.sourceSignalDisposable = nil;
        self.sourceSignal = nil;
    }
}

- (void)cancelWithError:(NSError *)error {
    [_extraErrors sendNext:error];
    [self cancel];
}

#pragma mark - Private

- (RACSignal *)p_executeNow {
    NSParameterAssert(![self isExecuting]);
    if ([self isExecuting]) {
        return _sourceSignal;
    }
    RACSignal *signal = self.executionBlock(_context);
    POSRX_CHECK(signal);
    RACMulticastConnection *connection = [[signal
        subscribeOn:self.scheduler]
        multicast:RACReplaySubject.subject];
    self.sourceSignal = [connection.signal deliverOn:self.scheduler];
    @weakify(self);
    [self.sourceSignal subscribeError:^(NSError *error) {
        @strongify(self);
        self.sourceSignal = nil;
    } completed:^{
        @strongify(self);
        self.sourceSignal = nil;
    }];
    self.sourceSignalDisposable = [connection connect];
    return _sourceSignal;
}

@end

#pragma mark - POSDirectTaskExecutor

@implementation POSDirectTaskExecutor

- (RACSignal *)pushTask:(POSTask *)task {
    return [task p_executeNow];
}

@end
