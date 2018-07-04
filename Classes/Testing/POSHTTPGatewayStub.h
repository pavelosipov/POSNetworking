//
//  POSHTTPGatewayStub.h
//  POSNetworking
//
//  Created by Pavel Osipov on 21/08/17.
//  Copyright © 2017 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGateway.h"

NS_ASSUME_NONNULL_BEGIN

@class POSHTTPResponse;
@class POSHTTPGatewayOptions;

typedef RACSignal<POSHTTPResponse *> * _Nonnull (^POSHTTPGatewayStubRequestHandler)(
    id<POSHTTPRequest> request,
    NSURL *hostURL,
    POSHTTPGatewayOptions * _Nullable options);

@interface POSHTTPGatewayStub : POSSchedulableObject <POSHTTPGateway>

- (instancetype)initWithRequestHandler:(POSHTTPGatewayStubRequestHandler)requestHandler NS_DESIGNATED_INITIALIZER;

POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
