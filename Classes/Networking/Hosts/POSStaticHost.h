//
//  POSStaticHost.h
//  POSNetworking
//
//  Created by Pavel Osipov on 11/04/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSHost.h"

NS_ASSUME_NONNULL_BEGIN

/// Host which URL will not change during its lifetime.
@interface POSStaticHost : POSHost

@property (nonatomic, readonly) NSURL *URL;

- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                       URL:(NSURL *)URL NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithID:(NSString *)ID gateway:(id<POSHTTPGateway>)gateway NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
