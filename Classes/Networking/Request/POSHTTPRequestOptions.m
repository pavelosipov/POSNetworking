//
//  POSHTTPRequestOptions.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestOptions.h"

#import "NSDictionary+POSNetworking.h"
#import "NSString+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPRequestOptions

- (instancetype)initWithURLPath:(nullable NSString *)URLPath
                       URLQuery:(nullable NSDictionary<NSString *,id<NSObject>> *)URLQuery
                           body:(nullable NSData *)body
                   headerFields:(nullable NSDictionary<NSString *,NSString *> *)headerFields
                responseTimeout:(nullable NSNumber *)responseTimeout
allowedUntrustedSSLCertificates:(nullable NSNumber *)allowed {
    if (self = [super init]) {
        _allowUntrustedSSLCertificates = allowed;
        _responseTimeout = responseTimeout;
        _headerFields = [headerFields copy];
        _URLQuery = [URLQuery copy];
        _URLPath = [URLPath copy];
        _body = body;
    }
    return self;
}

+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
                          with:(nullable POSHTTPRequestOptions *)target {
    if (!target && !source) {
        return nil;
    }
    if (!source) {
        return target;
    }
    if (!target) {
        return source;
    }
    NSString *URLPath;
    if (source.URLPath && target.URLPath) {
        URLPath = [NSString stringWithFormat:@"%@/%@", [source.URLPath pos_trimSymbol:@"/"], [target.URLPath pos_trimSymbol:@"/"]] ;
    } else {
        URLPath = source.URLPath ?: target.URLPath;
    }
    return [[POSHTTPRequestOptions alloc]
        initWithURLPath:URLPath
        URLQuery:[NSDictionary pos_merge:source->_URLQuery with:target->_URLQuery]
        body:(target.body ?: source.body)
        headerFields:[NSDictionary pos_merge:source->_headerFields with:target->_headerFields]
        responseTimeout:(target.responseTimeout ?: source.responseTimeout)
        allowedUntrustedSSLCertificates:(target.allowUntrustedSSLCertificates ?:
                                         source.allowUntrustedSSLCertificates)];
}

@end

#pragma mark -

@interface POSHTTPRequestOptionsBuilder ()

@property (nonatomic, nullable) NSNumber *allowUntrustedSSLCertificates;
@property (nonatomic, nullable) NSNumber *responseTimeout;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, nullable) NSDictionary<NSString *, id<NSObject>> *URLQuery;
@property (nonatomic, nullable) NSString *URLPath;
@property (nonatomic, nullable) NSData *body;

@end

@implementation POSHTTPRequestOptionsBuilder

- (POSHTTPRequestOptions *)build {
    return [[POSHTTPRequestOptions alloc]
        initWithURLPath:_URLPath
        URLQuery:_URLQuery
        body:_body
        headerFields:_headerFields
        responseTimeout:_responseTimeout
        allowedUntrustedSSLCertificates:_allowUntrustedSSLCertificates];
}

- (instancetype)withPath:(nullable NSString *)URLPath {
    self.URLPath = URLPath;
    return self;
}

- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields {
    self.headerFields = headerFields;
    return self;
}

- (instancetype)withQuery:(nullable NSDictionary<NSString *, id<NSObject>> *)URLQuery {
    self.URLQuery = URLQuery;
    return self;
}

- (instancetype)withBody:(nullable NSData *)body {
    self.body = body;
    return self;
}

- (instancetype)withAllowedUntrustedSSLCertificates:(nullable NSNumber *)allowed {
    self.allowUntrustedSSLCertificates = allowed;
    return self;
}

- (instancetype)withResponseTimeout:(nullable NSNumber *)responseTimeout {
    self.responseTimeout = responseTimeout;
    return self;
}

@end

NS_ASSUME_NONNULL_END
