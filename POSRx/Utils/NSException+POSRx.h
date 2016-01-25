//
//  NSException+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 25.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSException (POSRx)

/// Throws NSInternalInconsistencyException with specified message.
+ (void)posrx_throw:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END

#define POSRX_CHECK_EX(condition, description, ...) \
do { \
    NSAssert((condition), description, ##__VA_ARGS__); \
    if (!(condition)) { \
        [NSException posrx_throw:description, ##__VA_ARGS__]; \
    } \
} while (0)

#define POSRX_CHECK(condition) \
    POSRX_CHECK_EX(condition, ([NSString stringWithFormat:@"'%s' is false.", #condition]))
