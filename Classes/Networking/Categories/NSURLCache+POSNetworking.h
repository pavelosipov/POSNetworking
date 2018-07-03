//
//  NSURLCache+POSNetworking.h
//  POSNetworking
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLCache (POSNetworking)

+ (NSURLCache *)pos_leaksFreeCache;

@end

NS_ASSUME_NONNULL_END
