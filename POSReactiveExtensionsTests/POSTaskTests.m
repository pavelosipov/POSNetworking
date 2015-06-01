//
//  POSTaskTests.m
//  POSReactiveExtensions
//
//  Created by Osipov on 29.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <POSReactiveExtensions/POSReactiveExtensions.h>

@interface POSTaskTests : XCTestCase
@property (nonatomic) POSTask *task;
@end

@implementation POSTaskTests

- (void)testTaskExecutionSignalShouldEmitNOBeforeFirstExecution {
    POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
        return [RACSignal empty];
    }];
    __block BOOL executionValue = @YES;
    [task.executing subscribeNext:^(NSNumber *value) {
        executionValue = [value boolValue];
    }];
    XCTAssertFalse(executionValue);
}

- (void)testTaskResetValueAfterReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    __block int executionCount = 0;
    POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (++executionCount == 1) {
                [subscriber sendNext:@(1)];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
                [expectation fulfill];
            }
            return nil;
        }];
    }];
    [task.values subscribeNext:^(NSNumber *v) {
        XCTAssertNotNil(v);
    }];
    [task.executing subscribeNext:^(NSNumber *executing) {
        if (![executing boolValue] && executionCount < 2) {
            [task execute];
        }
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.values subscribeNext:^(NSNumber *value) {
            XCTAssertFalse(YES);
        }];
    }];
}

- (void)testTaskKeepLastValueUntilReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"document open"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@(1)];
            [subscriber sendCompleted];
            [expectation fulfill];
            return nil;
        }];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.values subscribeNext:^(NSNumber *value) {
            XCTAssertEqualObjects(value, @(1));
        }];
    }];
}

- (void)testTaskResetErrorAfterReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    __block int executionCount = 0;
    POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (++executionCount == 1) {
                [subscriber sendError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
            } else {
                [subscriber sendNext:@(1)];
                [subscriber sendCompleted];
                [expectation fulfill];
            }
            return nil;
        }];
    }];
    [task.errors subscribeNext:^(NSError *e) {
        XCTAssertNotNil(e);
    }];
    [task.executing subscribeNext:^(NSNumber *executing) {
        if (![executing boolValue] && executionCount < 2) {
            [task execute];
        }
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.errors subscribeNext:^(NSError *error) {
            XCTAssertFalse(YES);
        }];
    }];
}

- (void)testTaskKeepLastErrorUntilReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"document open"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
            [expectation fulfill];
            return nil;
        }];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.errors subscribeNext:^(NSError *error) {
            XCTAssertNotNil(error);
        }];
    }];
}

@end
