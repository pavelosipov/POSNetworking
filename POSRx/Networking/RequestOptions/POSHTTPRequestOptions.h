//
//  POSHTTPRequestOptions.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// HTTP related parameters.
@interface POSHTTPRequestOptions : NSObject <NSCopying, NSCoding>

/// YES value indicates, that HTTP request may be sent to hosts
/// with untrusted SSL certificates (for ex. self-signed).
/// May be nil if default value should be used.
@property (nonatomic, readonly, nullable) NSNumber *allowUntrustedSSLCertificates;

/// Specifies the maximum waiting time for response.
@property (nonatomic, readonly, nullable) NSNumber *responseTimeout;

/// Extra header fields, which will be appended to requests' header fields.
@property (nonatomic, readonly, nullable) NSDictionary *headerFields;

/// Extra query parameters, which will be appended to requests' query parameters.
@property (nonatomic, readonly, nullable) NSDictionary *queryParameters;

/// The convenience initializer.
- (instancetype)initWithHeaderFields:(nullable NSDictionary *)headerFields;

/// The convenience initializer.
- (instancetype)initWithQueryParameters:(nullable NSDictionary *)queryParameters;

/// The convenience initializer.
- (instancetype)initWithAllowUntrustedSSLCertificates:(nullable NSNumber *)allowUntrustedSSLCertificates;

/// The designated initializer.
- (instancetype)initWithHeaderFields:(nullable NSDictionary *)headerFields
                     queryParameters:(nullable NSDictionary *)queryParameters
       allowUntrustedSSLCertificates:(nullable NSNumber *)allowUntrustedSSLCertificates
                     responseTimeout:(nullable NSNumber *)responseTimeout;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (nullable POSHTTPRequestOptions *)merge:(nullable POSHTTPRequestOptions *)source
                                     with:(nullable POSHTTPRequestOptions *)target;

@end

NS_ASSUME_NONNULL_END
