//
//  POSHTTPPOST.h
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPPOST : POSHTTPRequestBuilder

- (instancetype)init;
- (instancetype)initWithHTTPMethod:(NSString *)HTTPMethod NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
