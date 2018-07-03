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

- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                       URL:(NSURL *)URL {
    POS_CHECK(ID);
    POS_CHECK(gateway);
    POS_CHECK(URL);
    if (self = [super initWithID:ID gateway:gateway]) {
        _URL = URL;
    }
    return self;
}

- (NSURL *)URL {
    return _URL;
}

@end

NS_ASSUME_NONNULL_END
