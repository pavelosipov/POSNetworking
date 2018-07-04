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

#pragma mark -

@interface POSHTTPGatewayOptionsBuilder ()
@property (nonatomic, nullable) POSHTTPRequestOptions *requestOptions;
@property (nonatomic, nullable) POSHTTPResponseOptions *responseOptions;
@end

@implementation POSHTTPGatewayOptionsBuilder

- (POSHTTPGatewayOptions *)build {
    return [[POSHTTPGatewayOptions alloc] initWithRequestOptions:_requestOptions responseOptions:_responseOptions];
}

- (instancetype)withRequestOptions:(nullable POSHTTPRequestOptions *)requestOptions {
    self.requestOptions = requestOptions;
    return self;
}

- (instancetype)withResponseOptions:(nullable POSHTTPResponseOptions *)responseOptions {
    self.responseOptions = responseOptions;
    return self;
}

@end

NS_ASSUME_NONNULL_END
