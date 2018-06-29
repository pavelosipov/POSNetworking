//
//  NSError+POSNetworking.m
//  POSNetworking
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSError+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSError (POSNetworking)

- (NSError *)pos_errorWithURL:(nullable NSURL *)URL {
    if (self.userInfo[NSURLErrorKey] || URL == nil) {
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

NS_ASSUME_NONNULL_END
