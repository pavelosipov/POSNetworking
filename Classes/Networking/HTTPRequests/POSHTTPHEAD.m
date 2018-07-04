//
//  POSHTTPHEAD.m
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPHEAD.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPHEAD

- (instancetype)init {
    return [super initWithHTTPMethod:@"HEAD"];
}

@end

NS_ASSUME_NONNULL_END
