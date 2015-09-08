//
//  NSException+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 25.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSException+POSRx.h"

@implementation NSException (POSRx)

+ (void)posrx_throw:(NSString *)format, ... {
    NSParameterAssert(format);
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

@end
