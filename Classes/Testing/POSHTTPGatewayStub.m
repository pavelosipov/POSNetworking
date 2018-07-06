//
//  POSHTTPGatewayStub.m
//  POSNetworking
//
//  Created by Pavel Osipov on 21/08/17.
//  Copyright © 2017 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGatewayStub.h"
#import "POSHTTPGatewayOptions.h"
#import "POSHTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPGatewayStub ()
@property (nonatomic, copy) POSHTTPGatewayStubRequestHandler requestHandler;
@end

@implementation POSHTTPGatewayStub

@synthesize options = _options;

- (instancetype)initWithRequestHandler:(POSHTTPGatewayStubRequestHandler)requestHandler {
    POS_CHECK(requestHandler);
    if (self = [super initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler safetyPredicate:nil]) {
        _requestHandler = [requestHandler copy];
    }
    return self;
}

#pragma mark POSHTTPGateway

- (NSURLSession *)foregroundSession {
    POS_CHECK(!"Not supported");
    return nil;
}

- (nullable NSURLSession *)backgroundSession {
    return nil;
}

- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                  hostOptions:(nullable POSHTTPGatewayOptions *)hostOptions
                 extraOptions:(nullable POSHTTPGatewayOptions *)extraOptions {
    @weakify(self)
    POSHTTPGatewayOptions *options = [self p_combineSelfOptions:self.options
                                                    hostOptions:hostOptions
                                                   extraOptions:extraOptions
                                                 requestOptions:request.options];
    return [POSTask createTask:^RACSignal * _Nonnull(POSTask *task) {
        @strongify(self);
        return [self.requestHandler(request, hostURL, options) takeUntil:self.rac_willDeallocSignal];
    } scheduler:self.scheduler];
}

- (void)invalidateBackgroundTasksWithCompletionHandler:(dispatch_block_t)completionHandler {
    POS_CHECK(completionHandler);
    completionHandler();
}

- (RACSignal *)invalidateForced:(BOOL)forced {
    return [RACSignal empty];
}

#pragma mark - Private

- (nullable POSHTTPGatewayOptions *)p_combineSelfOptions:(nullable POSHTTPGatewayOptions *)gatewayOptions
                                             hostOptions:(nullable POSHTTPGatewayOptions *)hostOptions
                                            extraOptions:(nullable POSHTTPGatewayOptions *)extraOptions
                                          requestOptions:(POSHTTPRequestOptions *)requestOptions {
    POSHTTPGatewayOptions *combinedOptions = gatewayOptions;
    combinedOptions = [POSHTTPGatewayOptions merge:combinedOptions with:hostOptions];
    combinedOptions = [POSHTTPGatewayOptions merge:combinedOptions withRequestOptions:requestOptions];
    combinedOptions = [POSHTTPGatewayOptions merge:combinedOptions with:extraOptions];
    return combinedOptions;
}

@end

NS_ASSUME_NONNULL_END
