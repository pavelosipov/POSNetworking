//
//  POSHTTPGatewayStub.m
//  POSNetworking
//
//  Created by Pavel Osipov on 21/08/17.
//  Copyright © 2017 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGatewayStub.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPGatewayStub ()
@property (nonatomic, copy) RACSignal *(^requestHandler)(id<POSHTTPRequest> request, NSURL *hostURL);
@end

@implementation POSHTTPGatewayStub {
    POSHTTPRequestExecutionOptions * __nullable _options;
}
@synthesize options = _options;

- (instancetype)initWithRequestHandler:(RACSignal *(^)(id<POSHTTPRequest>, NSURL *))requestHandler {
    POSRX_CHECK(requestHandler);
    if (self = [super initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler]) {
        _requestHandler = [requestHandler copy];
    }
    return self;
}

#pragma mark POSHTTPGateway

- (NSURLSession *)foregroundSession {
    POSRX_CHECK(!"Not supported");
    return nil;
}

- (nullable NSURLSession *)backgroundSession {
    return nil;
}

- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                      options:(nullable POSHTTPRequestExecutionOptions *)options {
    @weakify(self)
    return [POSTask createTask:^RACSignal * _Nonnull(POSTask *task) {
        @strongify(self);
        return [self.requestHandler(request, hostURL) takeUntil:self.rac_willDeallocSignal];
    } scheduler:self.scheduler];
}

- (void)recoverBackgroundUploadRequestsUsingBlock:(void(^)(NSArray *uploadRequests))block {
    if (block) {
        block(NSArray.new);
    }
}

- (RACSignal *)invalidateCancelingRequests:(BOOL)cancelPendingRequests {
    return [RACSignal empty];
}

- (void)reconnectToBackgroundSession {
}

@end

NS_ASSUME_NONNULL_END
