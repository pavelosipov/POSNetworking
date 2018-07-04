//
//  POSStaticHost.m
//  POSNetworking
//
//  Created by Pavel Osipov on 11/04/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSStaticHost.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSStaticHost

@synthesize URL = _URL;

- (instancetype)initWithURL:(NSURL *)URL
                    gateway:(id<POSHTTPGateway>)gateway
                    options:(nullable POSHTTPGatewayOptions *)options {
    POS_CHECK(URL);
    POS_CHECK(gateway);
    if (self = [super initWithGateway:gateway options:options]) {
        _URL = URL;
    }
    return self;
}

- (NSURL *)URL {
    return _URL;
}

@end

NS_ASSUME_NONNULL_END
