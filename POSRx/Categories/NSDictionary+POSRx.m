//
//  NSDictionary+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSDictionary+POSRx.h"

NS_INLINE NSString *POSCreateStringByAddingPercentEscapes(NSString *unescaped, NSString *escapedSymbols) {
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault,
        (CFStringRef)unescaped,
        NULL,
        (CFStringRef)escapedSymbols,
        kCFStringEncodingUTF8);
}

@implementation NSDictionary (POSRx)

- (NSData *)posrx_URLBody {
    if (!self.count) {
        return [NSData new];
    }
    NSMutableString *query = [NSMutableString new];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSString *pairFormat = query.length ? @"&%@=%@" : @"%@=%@";
        [query appendString:[NSString stringWithFormat:pairFormat,
                             key,
                             POSCreateStringByAddingPercentEscapes(value, @"!*'();:@&=+$,/?%#[]")]];
    }];
    return [query dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSString *)posrx_URLQuery {
    NSMutableString *query = [NSMutableString new];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSString *pairFormat = query.length ? @"&%@=%@" : @"%@=%@";
        [query appendString:[NSString stringWithFormat:pairFormat, key, value]];
    }];
    return query;
}

@end
