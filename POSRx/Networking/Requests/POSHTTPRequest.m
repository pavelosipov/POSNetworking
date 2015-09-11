//
//  POSHTTPRequest.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"
#import "POSHTTPRequestOptions.h"
#import "POSHTTPGateway.h"
#import "NSException+POSRx.h"
#import "NSURL+POSRx.h"
#import "NSObject+POSRx.h"

NS_INLINE NSString *POSStringFromHTTPRequestType(POSHTTPRequestType type) {
    switch (type) {
        case POSHTTPRequestTypeGET:  return @"GET";
        case POSHTTPRequestTypeHEAD: return @"HEAD";
        case POSHTTPRequestTypePOST: return @"POST";
        case POSHTTPRequestTypePUT:  return @"PUT";
    }
}

#pragma mark -

@interface POSHTTPRequest ()
@property (nonatomic) POSHTTPRequestType type;
@property (nonatomic) NSString *endpointMethod;
@property (nonatomic) NSData *body;
@property (nonatomic) NSDictionary *headerFields;
@end

@implementation POSHTTPRequest

#pragma mark Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _type = POSHTTPRequestTypeGET;
        _endpointMethod = nil;
        _body = nil;
        _headerFields = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
        _endpointMethod = [aDecoder decodeObjectForKey:@"endpointMethod"];
        _body = [aDecoder decodeObjectForKey:@"body"];
        _headerFields = [aDecoder decodeObjectForKey:@"headerFields"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_type) forKey:@"type"];
    if (_endpointMethod) {
        [aCoder encodeObject:_endpointMethod forKey:@"endpointMethod"];
    }
    if (_body) {
        [aCoder encodeObject:_body forKey:@"body"];
    }
    if (_headerFields) {
        [aCoder encodeObject:_headerFields forKey:@"headerFields"];
    }
}

- (instancetype)initWithType:(POSHTTPRequestType)type
              endpointMethod:(NSString *)endpointMethod
                        body:(NSData *)body
                headerFields:(NSDictionary *)headerFields {
    if (self = [super init]) {
        _type = type;
        _endpointMethod = endpointMethod;
        _body = body;
        _headerFields = headerFields;
    }
    return self;
}

#pragma mark Hidden

- (id<POSURLSessionTask>)taskWithURL:(NSURL *)hostURL
                          forGateway:(id<POSHTTPGateway>)gateway
                             options:(POSHTTPRequestOptions *)options {
    NSURLRequest *request = [self requestWithURL:hostURL options:options];
    return [gateway.foregroundSession dataTaskWithRequest:request];
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options {
    POSRX_CHECK(hostURL);
    NSURL *fullURL = [hostURL posrx_URLByAppendingEscapedPathComponent:_endpointMethod];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:fullURL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:15.0];
    request.HTTPMethod = POSStringFromHTTPRequestType(_type);
    NSDictionary *allHeaderFields;
    if (!_headerFields) {
        allHeaderFields = options.headerFields;
    } else {
        NSMutableDictionary *headerFields = [_headerFields mutableCopy];
        [headerFields addEntriesFromDictionary:options.headerFields];
        allHeaderFields = headerFields;
    }
    if (allHeaderFields) {
        request.allHTTPHeaderFields = allHeaderFields;
    }
    if (_body) {
        request.HTTPBody = _body;
    }
    return request;
}

@end

#pragma mark -

@implementation POSMutableHTTPRequest
@dynamic type;
@dynamic endpointMethod;
@dynamic body;
@dynamic headerFields;
@end
