//
//  NSURLCache+POSNetworking.m
//  POSNetworking
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSURLCache+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSURLCache (POSNetworking)

+ (NSURLCache *)pos_leaksFreeCache {
    // Preventing memory leaks as described at http://ubm.io/1mObM8d
    return [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
}

@end

NS_ASSUME_NONNULL_END
