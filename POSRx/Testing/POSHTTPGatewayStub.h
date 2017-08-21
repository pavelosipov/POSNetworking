//
//  POSHTTPGatewayStub.h
//  POSRx
//
//  Created by Pavel Osipov on 21/08/17.
//  Copyright © 2017 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPGatewayStub : POSSchedulableObject <POSHTTPGateway>

- (instancetype)initWithRequestHandler:(RACSignal *(^)(id<POSHTTPRequest> request, NSURL *hostURL))requestHandler;

POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
