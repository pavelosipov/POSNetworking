//
//  POSHTTPRequestOptions.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestOptions.h"
#import "NSDictionary+POSRx.h"

@implementation POSHTTPRequestOptions

- (instancetype)initWithHeaderFields:(NSDictionary *)headerFields
                     queryParameters:(NSDictionary *)queryParameters
       allowUntrustedSSLCertificates:(NSNumber *)allowUntrustedSSLCertificates {
    if (self = [super init]) {
        _headerFields = [headerFields copy];
        _queryParameters = [queryParameters copy];
        _allowUntrustedSSLCertificates = allowUntrustedSSLCertificates;
    }
    return self;
}

- (instancetype)initWithAllowUntrustedSSLCertificates:(NSNumber *)allowUntrustedSSLCertificates {
    return [self initWithHeaderFields:nil
                      queryParameters:nil
        allowUntrustedSSLCertificates:allowUntrustedSSLCertificates];
}

- (instancetype)initWithHeaderFields:(NSDictionary *)headerFields {
    return [self initWithHeaderFields:headerFields
                      queryParameters:nil
        allowUntrustedSSLCertificates:nil];
}

- (instancetype)initWithQueryParameters:(NSDictionary *)queryParameters {
    return [self initWithHeaderFields:nil
                      queryParameters:queryParameters
        allowUntrustedSSLCertificates:nil];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _allowUntrustedSSLCertificates = [aDecoder decodeObjectForKey:@"allowUntrustedSSLCertificates"];
        _headerFields = [aDecoder decodeObjectForKey:@"headerFields"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_allowUntrustedSSLCertificates) {
        [aCoder encodeObject:_allowUntrustedSSLCertificates forKey:@"allowUntrustedSSLCertificates"];
    }
    if (_headerFields) {
        [aCoder encodeObject:_headerFields forKey:@"headerFields"];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) clone = [[[self class] allocWithZone:zone]
                          initWithHeaderFields:[_headerFields copy]
                          queryParameters:[_queryParameters copy]
                          allowUntrustedSSLCertificates:_allowUntrustedSSLCertificates];
    return clone;
}

+ (POSHTTPRequestOptions *)merge:(POSHTTPRequestOptions *)source
                            with:(POSHTTPRequestOptions *)target {
    if (!target && !source) {
        return nil;
    }
    if (!source) {
        return [target copy];
    }
    if (!target) {
        return [source copy];
    }
    NSNumber *mergedAllowUntrustedSSLCertificates = (target.allowUntrustedSSLCertificates ?:
                                                     source.allowUntrustedSSLCertificates);
    return [[POSHTTPRequestOptions alloc]
            initWithHeaderFields:[NSDictionary posrx_merge:source->_headerFields with:target->_headerFields]
            queryParameters:[NSDictionary posrx_merge:source->_queryParameters with:target->_queryParameters]
            allowUntrustedSSLCertificates:mergedAllowUntrustedSSLCertificates];
}

@end
