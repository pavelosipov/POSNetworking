//
//  POSHTTPResponse.m
//  POSNetworking
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPResponse.h"
#import "NSString+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPResponse

- (instancetype)initWithData:(nullable NSData *)data metadata:(NSHTTPURLResponse *)metadata {
    POS_CHECK(metadata);
    if (self = [super init]) {
        _data = data;
        _metadata = metadata;
    }
    return self;
}

- (instancetype)initWithData:(nullable NSData *)data {
    return [self
        initWithData:data
        metadata:[[NSHTTPURLResponse alloc]
            initWithURL:[[NSURL alloc] initWithString:@"http://unspecified.com"]
            statusCode:200
            HTTPVersion:@"1.1"
            headerFields:[NSDictionary new]]];
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode {
    return [self initWithStatusCode:statusCode hostURL:nil];
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode hostURL:(nullable NSURL *)hostURL {
    return [self
        initWithData:nil
        metadata:[[NSHTTPURLResponse alloc]
            initWithURL:(hostURL ?: [@"http://unspecified.com" pos_URL])
            statusCode:statusCode
            HTTPVersion:@"1.1"
            headerFields:[NSDictionary new]]];
}

#pragma mark - NSObject

- (NSString *)description {
    NSString *dataText = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"HTTPResponse{URL=%@, statusCode=%@, data='%@'}",
        _metadata.URL,
        @(_metadata.statusCode),
        (dataText ? dataText : _data)];
}

@end

NS_ASSUME_NONNULL_END
