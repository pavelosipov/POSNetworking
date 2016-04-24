//
//  POSHTTPMethod.m
//  POSRx
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestMethod.h"
#import "NSDictionary+POSRx.h"
#import "NSException+POSRx.h"
#import "NSURL+POSRx.h"

@interface POSHTTPRequestMethod()
@property (nonatomic) NSString *path;
@property (nonatomic) NSDictionary *query;
@end

@implementation POSHTTPRequestMethod

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _path = [aDecoder decodeObjectForKey:@"path"];
        _query = [aDecoder decodeObjectForKey:@"query"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_path) {
        [aCoder encodeObject:_path forKey:@"path"];
    }
    if (_query) {
        [aCoder encodeObject:_query forKey:@"query"];
    }
}

+ (instancetype)path:(NSString *)path {
    return [self path:path query:nil];
}

+ (instancetype)query:(NSDictionary *)query {
    return [self path:nil query:query];
}

+ (instancetype)path:(NSString *)path
               query:(NSDictionary *)query {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod new];
    if ([path hasPrefix:@"/"]) {
        method.path = [path substringFromIndex:1];
    } else {
        method.path =  [path copy];
    }
    method.query = [query copy];
    return method;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@{path='%@', query='%@'}",
            [super description], _path, [_query posrx_URLQuery]];
}

@end
