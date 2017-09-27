//
//  POSHTTPRequestOptions.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestOptions.h"
#import "NSDictionary+POSRx.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSHTTPRequestOptions

- (instancetype)initWithHeaderFields:(nullable NSDictionary *)headerFields
                     queryParameters:(nullable NSDictionary *)queryParameters
       allowUntrustedSSLCertificates:(nullable NSNumber *)allowUntrustedSSLCertificates
                     responseTimeout:(nullable NSNumber *)responseTimeout {
    if (self = [super init]) {
        _headerFields = [headerFields copy];
        _queryParameters = [queryParameters copy];
        _allowUntrustedSSLCertificates = allowUntrustedSSLCertificates;
        _responseTimeout = responseTimeout;
    }
    return self;
}

- (instancetype)initWithAllowUntrustedSSLCertificates:(nullable NSNumber *)allowUntrustedSSLCertificates {
    return [self initWithHeaderFields:nil
                      queryParameters:nil
        allowUntrustedSSLCertificates:allowUntrustedSSLCertificates
                      responseTimeout:nil];
}

- (instancetype)initWithHeaderFields:(nullable NSDictionary *)headerFields {
    return [self initWithHeaderFields:headerFields
                      queryParameters:nil
        allowUntrustedSSLCertificates:nil
                      responseTimeout:nil];
}

- (instancetype)initWithQueryParameters:(nullable NSDictionary *)queryParameters {
    return [self initWithHeaderFields:nil
                      queryParameters:queryParameters
        allowUntrustedSSLCertificates:nil
                      responseTimeout:nil];
}

#pragma mark NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _allowUntrustedSSLCertificates = [aDecoder decodeObjectForKey:@"allowUntrustedSSLCertificates"];
        _headerFields = [aDecoder decodeObjectForKey:@"headerFields"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_allowUntrustedSSLCertificates != nil) {
        [aCoder encodeObject:_allowUntrustedSSLCertificates forKey:@"allowUntrustedSSLCertificates"];
    }
    if (_headerFields) {
        [aCoder encodeObject:_headerFields forKey:@"headerFields"];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    typeof(self) clone = [[[self class] allocWithZone:zone]
                          initWithHeaderFields:[_headerFields copy]
                          queryParameters:[_queryParameters copy]
                          allowUntrustedSSLCertificates:_allowUntrustedSSLCertificates
                          responseTimeout:_responseTimeout];
    return clone;
}

+ (nullable POSHTTPRequestOptions *)merge:(nullable POSHTTPRequestOptions *)source
                                     with:(nullable POSHTTPRequestOptions *)target {
    if (!target && !source) {
        return nil;
    }
    if (!source) {
        return [target copy];
    }
    if (!target) {
        return [source copy];
    }
    NSNumber *allowUntrustedSSLCertificates = (target.allowUntrustedSSLCertificates ?:
                                               source.allowUntrustedSSLCertificates);
    NSNumber *responseTimeout = (target.responseTimeout ?: source.responseTimeout);
    return [[POSHTTPRequestOptions alloc]
            initWithHeaderFields:[NSDictionary posrx_merge:source->_headerFields with:target->_headerFields]
            queryParameters:[NSDictionary posrx_merge:source->_queryParameters with:target->_queryParameters]
            allowUntrustedSSLCertificates:allowUntrustedSSLCertificates
            responseTimeout:responseTimeout];
}

@end

NS_ASSUME_NONNULL_END
