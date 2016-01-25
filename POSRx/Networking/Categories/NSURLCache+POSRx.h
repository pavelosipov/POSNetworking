//
//  NSURLCache+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLCache (POSRx)

+ (NSURLCache *)posrx_leaksFreeCache;

@end

NS_ASSUME_NONNULL_END
