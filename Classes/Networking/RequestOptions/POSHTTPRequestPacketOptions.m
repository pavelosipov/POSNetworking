//
//  POSHTTPRequestPacketOptions.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestPacketOptions.h"
#import "NSDictionary+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPRequestPacketOptions ()

@property (nonatomic, nullable) NSNumber *allowUntrustedSSLCertificates;
@property (nonatomic, nullable) NSNumber *responseTimeout;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, nullable) NSDictionary<NSString *, id<NSObject>> *URLQuery;

@end

@implementation POSHTTPRequestPacketOptions

+ (nullable instancetype)merge:(nullable POSHTTPRequestPacketOptions *)source
                          with:(nullable POSHTTPRequestPacketOptions *)target {
    if (!target && !source) {
        return nil;
    }
    if (!source) {
        return [target copy];
    }
    if (!target) {
        return [source copy];
    }
    POSHTTPRequestPacketOptions *merged = [[POSHTTPRequestPacketOptions alloc] init];
    merged.headerFields = [NSDictionary pos_merge:source->_headerFields with:target->_headerFields];
    merged.URLQuery = [NSDictionary pos_merge:source->_URLQuery with:target->_URLQuery];
    merged.allowUntrustedSSLCertificates = (target.allowUntrustedSSLCertificates ?:
                                            source.allowUntrustedSSLCertificates);
    merged.responseTimeout = (target.responseTimeout ?: source.responseTimeout);
    return merged;
}

@end

#pragma mark -

@interface POSHTTPRequestPacketOptionsBuilder ()

@property (nonatomic, nullable) NSNumber *allowUntrustedSSLCertificates;
@property (nonatomic, nullable) NSNumber *responseTimeout;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, nullable) NSDictionary<NSString *, id<NSObject>> *URLQuery;

@end

@implementation POSHTTPRequestPacketOptionsBuilder

- (POSHTTPRequestPacketOptions *)build {
    POSHTTPRequestPacketOptions *options = [[POSHTTPRequestPacketOptions alloc] init];
    options.headerFields = _headerFields;
    options.URLQuery = _URLQuery;
    options.allowUntrustedSSLCertificates = _allowUntrustedSSLCertificates;
    options.responseTimeout = _responseTimeout;
    return options;
}

- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields {
    _headerFields = [headerFields copy];
    return self;
}

- (instancetype)withURLQuery:(nullable NSDictionary<NSString *, id<NSObject>> *)URLQuery {
    _URLQuery = [URLQuery copy];
    return self;
}

- (instancetype)withAllowedUntrustedSSLCertificates:(nullable NSNumber *)allowed {
    _allowUntrustedSSLCertificates = allowed;
    return self;
}

- (instancetype)withResponseTimeout:(nullable NSNumber *)responseTimeout {
    _responseTimeout = responseTimeout;
    return self;
}

@end

NS_ASSUME_NONNULL_END
