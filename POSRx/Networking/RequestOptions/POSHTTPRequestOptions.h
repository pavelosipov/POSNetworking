//
//  POSHTTPRequestOptions.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

/// HTTP related parameters.
@interface POSHTTPRequestOptions : NSObject <NSCopying, NSCoding>

/// YES value indicates, that HTTP request may be sent to hosts
/// with untrusted SSL certificates (for ex. self-signed).
/// May be nil if default value should be used.
@property (nonatomic, readonly) NSNumber *allowUntrustedSSLCertificates;

/// Extra header fields, which will be appended to requests' header fields.
@property (nonatomic, readonly) NSDictionary *headerFields;

/// Extra query parameters, which will be appended to requests' query parameters.
@property (nonatomic, readonly) NSDictionary *queryParameters;

/// The convenience initializer.
- (instancetype)initWithHeaderFields:(NSDictionary *)headerFields;

/// The convenience initializer.
- (instancetype)initWithQueryParameters:(NSDictionary *)queryParameters;

/// The convenience initializer.
- (instancetype)initWithAllowUntrustedSSLCertificates:(NSNumber *)allowUntrustedSSLCertificates;

/// The designated initializer.
- (instancetype)initWithHeaderFields:(NSDictionary *)headerFields
                     queryParameters:(NSDictionary *)queryParameters
       allowUntrustedSSLCertificates:(NSNumber *)allowUntrustedSSLCertificates;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (POSHTTPRequestOptions *)merge:(POSHTTPRequestOptions *)source
                            with:(POSHTTPRequestOptions *)target;

@end
