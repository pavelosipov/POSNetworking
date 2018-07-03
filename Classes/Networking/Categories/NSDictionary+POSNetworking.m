//
//  NSDictionary+POSRx.m
//  POSNetworking
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSDictionary+POSNetworking.h"
#import "NSString+POSNetworking.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSDictionary (POSNetworking)

- (NSData *)pos_URLQueryBody {
    if (!self.count) {
        return [NSData new];
    }
    NSMutableString *query = [NSMutableString new];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        NSString *pairFormat = query.length ? @"&%@=%@" : @"%@=%@";
        [query appendFormat:pairFormat, key, [[value description] pos_URLEncoded]];
    }];
    return [query dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *)pos_URLJSONBody {
    POS_CHECK([NSJSONSerialization isValidJSONObject:self]);
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    POS_CHECK_EX(data, @"Failed to encode %@ to JSON: %@", self, error);
    return data;
}

- (NSString *)pos_URLQuery {
    return [self pos_URLQueryEncoded:YES];
}

- (NSString *)pos_URLQueryEncoded:(BOOL)encoded {
    NSMutableString *query = [NSMutableString new];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        NSString *pairFormat = query.length ? @"&%@=%@" : @"%@=%@";
        NSString *queryValue = [value description];
        if (encoded) {
            queryValue = [queryValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [query appendFormat:pairFormat, key, queryValue];
    }];
    return query;
}

+ (nullable NSDictionary *)pos_merge:(nullable NSDictionary *)source with:(nullable NSDictionary *)target {
    if (source == target) {
        return source;
    }
    if (!source) {
        return [target copy];
    }
    if (!target) {
        return [source copy];
    }
    NSMutableDictionary *merged = [source mutableCopy];
    [merged addEntriesFromDictionary:target];
    return merged;
}

@end

NS_ASSUME_NONNULL_END
