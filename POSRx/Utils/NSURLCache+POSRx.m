//
//  NSURLCache+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSURLCache+POSRx.h"

@implementation NSURLCache (POSRx)

+ (NSURLCache *)posrx_leaksFreeCache {
    // Preventing memory leaks as described at http://ubm.io/1mObM8d
    return [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
}

@end
