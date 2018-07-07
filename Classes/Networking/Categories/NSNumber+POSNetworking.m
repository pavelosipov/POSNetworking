//
//  NSNumber+POSNetworking.m
//  POSNetworking
//
//  Created by Pavel Osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSNumber+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSNumber (POSNetworking)

- (BOOL)pos_contains2XXStatusCode {
    return self.integerValue / 100 == 2;
}

@end

NS_ASSUME_NONNULL_END
