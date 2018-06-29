//
//  MRCStaticHost.m
//  MRCloudSDK
//
//  Created by Pavel Osipov on 11/04/16.
//  Copyright © 2016 Mail.Ru Group. All rights reserved.
//

#import "MRCStaticHost.h"

NS_ASSUME_NONNULL_BEGIN

@implementation MRCStaticHost {
     NSURL * __nonnull _URL;
}

- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<MRCTracker>)tracker
                       URL:(NSURL *)URL {
    POSRX_CHECK(ID);
    POSRX_CHECK(gateway);
    POSRX_CHECK(URL);
    if (self = [super initWithID:ID gateway:gateway tracker:tracker]) {
        _URL = URL;
    }
    return self;
}

- (nullable NSURL *)URL {
    return _URL;
}

@end

NS_ASSUME_NONNULL_END
