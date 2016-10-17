//
//  NSDictionary+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSDictionary+POSRx.h"
#import "NSString+POSRx.h"
#import "NSException+POSRx.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDictionary (POSRx)

+ (nullable NSDictionary *)posrx_merge:(nullable NSDictionary *)sourceDictionary
                                  with:(nullable NSDictionary *)targetDictionary {
    if (sourceDictionary == targetDictionary) {
        return sourceDictionary;
    }
    if (!sourceDictionary) {
        return [targetDictionary copy];
    }
    if (!targetDictionary) {
        return [sourceDictionary copy];
    }
    NSMutableDictionary *resultDictionary = [sourceDictionary mutableCopy];
    [resultDictionary addEntriesFromDictionary:targetDictionary];
    return resultDictionary;
}

- (NSData *)posrx_URLQueryBody {
    if (!self.count) {
        return [NSData new];
    }
    NSMutableString *query = [NSMutableString new];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        NSString *pairFormat = query.length ? @"&%@=%@" : @"%@=%@";
        [query appendString:[NSString stringWithFormat:pairFormat,
                             key,
                             [[value description] posrx_percentEscaped]]];
    }];
    return [query dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *)posrx_URLJSONBody {
    POSRX_CHECK([NSJSONSerialization isValidJSONObject:self]);
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0
                                                     error:&error];
    POSRX_CHECK_EX(data, @"Failed to encode %@ to JSON: %@", self, error);
    return data;
}

- (NSString *)posrx_URLQuery {
    return [self posrx_URLQueryUsingPercentEncoding:YES];
}

- (NSString *)posrx_URLQueryUsingPercentEncoding:(BOOL)usePercentEncoding {
    NSMutableString *query = [NSMutableString new];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        NSString *pairFormat = query.length ? @"&%@=%@" : @"%@=%@";
        NSString *queryValue = [value description];
        if (usePercentEncoding) {
            queryValue = [queryValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [query appendFormat:pairFormat, key, queryValue];
    }];
    return query;
}

@end

NS_ASSUME_NONNULL_END
