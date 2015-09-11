//
//  NSError+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSError+POSRx.h"

@implementation NSError (POSRx)

- (NSError *)errorWithURL:(NSURL *)URL {
    if (self.userInfo[NSURLErrorKey]) {
        return self;
    }
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
    if (!userInfo) {
        userInfo = [NSMutableDictionary new];
    }
    userInfo[NSURLErrorKey] = [URL copy];
    NSError *error = [NSError errorWithDomain:self.domain
                                         code:self.code
                                     userInfo:userInfo];
    return error;
}

@end
