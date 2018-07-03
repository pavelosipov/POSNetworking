//
//  NSHTTPURLResponse+POSNetworking.m
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSHTTPURLResponse+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSHTTPURLResponse (POSNetworking)

- (BOOL)pos_contains2XXStatusCode {
    return self.statusCode / 100 == 2;
}

@end

NS_ASSUME_NONNULL_END
