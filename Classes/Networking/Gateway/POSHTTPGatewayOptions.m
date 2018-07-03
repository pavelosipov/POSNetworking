//
//  POSHTTPGatewayOptions.m
//  POSNetworking
//
//  Created by Pavel Osipov on 19.08.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGatewayOptions.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPResponseOptions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPGatewayOptions

- (instancetype)initWithRequestOptions:(nullable POSHTTPRequestOptions *)requestOptions
                       responseOptions:(nullable POSHTTPResponseOptions *)responseOptions {
    if (self = [super init]) {
        _requestOptions = requestOptions;
        _responseOptions = responseOptions;
    }
    return self;
}

+ (nullable instancetype)merge:(nullable POSHTTPGatewayOptions *)source
                          with:(nullable POSHTTPGatewayOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPGatewayOptions alloc]
        initWithRequestOptions:[POSHTTPRequestOptions merge:source.requestOptions with:target.requestOptions]
        responseOptions:(target.responseOptions ?: source.responseOptions)];
}

+ (nullable instancetype)merge:(nullable POSHTTPGatewayOptions *)source
            withRequestOptions:(nullable POSHTTPRequestOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPGatewayOptions alloc]
        initWithRequestOptions:[POSHTTPRequestOptions merge:source.requestOptions with:target]
        responseOptions:source.responseOptions];
}

+ (nullable instancetype)merge:(nullable POSHTTPGatewayOptions *)source
           withResponseOptions:(nullable POSHTTPResponseOptions *)target {
    if (!source && !target) {
        return nil;
    }
    return [[POSHTTPGatewayOptions alloc]
        initWithRequestOptions:source.requestOptions
        responseOptions:(target ?: source.responseOptions)];
}

@end

NS_ASSUME_NONNULL_END
