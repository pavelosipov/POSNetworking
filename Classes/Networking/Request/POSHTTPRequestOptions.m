//
//  POSHTTPRequestOptions.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestOptions.h"
#import "NSDictionary+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPRequestOptions

- (instancetype)initWithAllowedUntrustedSSLCertificates:(nullable NSNumber *)allowed
                                        responseTimeout:(nullable NSNumber *)responseTimeout
                                           headerFields:(nullable NSDictionary<NSString *,NSString *> *)headerFields
                                               URLQuery:(nullable NSDictionary<NSString *,id<NSObject>> *)URLQuery
                                                URLPath:(nullable NSString *)URLPath {
    if (self = [super init]) {
        _allowUntrustedSSLCertificates = allowed;
        _responseTimeout = responseTimeout;
        _headerFields = [headerFields copy];
        _URLQuery = [URLQuery copy];
        _URLPath = [URLPath copy];
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
        URLPath = [target.URLPath hasPrefix:@"/"] ? [target.URLPath substringFromIndex:1] : target.URLPath;
    } else {
        URLPath = source.URLPath ?: target.URLPath;
    }
    return [[POSHTTPRequestOptions alloc]
        initWithAllowedUntrustedSSLCertificates:(target.allowUntrustedSSLCertificates ?:
                                                     source.allowUntrustedSSLCertificates)
        responseTimeout:(target.responseTimeout ?: source.responseTimeout)
        headerFields:[NSDictionary pos_merge:source->_headerFields with:target->_headerFields]
        URLQuery:[NSDictionary pos_merge:source->_URLQuery with:target->_URLQuery]
        URLPath:URLPath];
}

@end

#pragma mark -

@interface POSHTTPRequestOptionsBuilder ()

@property (nonatomic, nullable) NSNumber *allowUntrustedSSLCertificates;
@property (nonatomic, nullable) NSNumber *responseTimeout;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, nullable) NSDictionary<NSString *, id<NSObject>> *URLQuery;
@property (nonatomic, nullable) NSString *URLPath;

@end

@implementation POSHTTPRequestOptionsBuilder

- (POSHTTPRequestOptions *)build {
    return [[POSHTTPRequestOptions alloc]
        initWithAllowedUntrustedSSLCertificates:_allowUntrustedSSLCertificates
        responseTimeout:_responseTimeout
        headerFields:_headerFields
        URLQuery:_URLQuery
        URLPath:_URLPath];
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
