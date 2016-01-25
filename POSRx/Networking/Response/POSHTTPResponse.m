//
//  POSHTTPResponse.m
//  POSRx
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPResponse.h"
#import "NSException+POSRx.h"

@implementation POSHTTPResponse

#pragma mark Lifecycle

- (instancetype)initWithData:(nullable NSData *)data metadata:(NSHTTPURLResponse *)metadata {
    POSRX_CHECK(metadata);
    if (self = [super init]) {
        _data = data;
        _metadata = metadata;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        _data = data;
        _metadata = [[NSHTTPURLResponse alloc]
                     initWithURL:[[NSURL alloc] initWithString:@"http://unspecified.com"]
                     statusCode:200
                     HTTPVersion:@"1.1"
                     headerFields:[NSDictionary new]];
    }
    return self;
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode {
    if (self = [super init]) {
        _data = nil;
        _metadata = [[NSHTTPURLResponse alloc]
                     initWithURL:[[NSURL alloc] initWithString:@"http://unspecified.com"]
                     statusCode:statusCode
                     HTTPVersion:@"1.1"
                     headerFields:[NSDictionary new]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _data = [aDecoder decodeObjectForKey:@"data"];
        _metadata = [aDecoder decodeObjectForKey:@"metadata"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_data) {
        [aCoder encodeObject:_data forKey:@"data"];
    }
    if (_metadata) {
        [aCoder encodeObject:_metadata forKey:@"metadata"];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone]
            initWithData:[_data copy]
            metadata:[_metadata copy]];
}

#pragma mark NSObject

- (NSString *)description {
    NSString *dataText = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"HTTPResponse{URL=%@, statusCode=%@, data='%@'}",
            _metadata.URL,
            @(_metadata.statusCode),
            (dataText ? dataText : _data)];
}

@end
