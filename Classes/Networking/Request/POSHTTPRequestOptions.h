//
//  POSHTTPRequestOptions.h
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

///
/// Contains parameters related to HTTP connection.
///
@interface POSHTTPRequestOptions : NSObject

/// YES value indicates, that HTTP request may be sent to hosts
/// with untrusted SSL certificates (for ex. self-signed).
/// May be nil if default value should be used.
@property (nonatomic, readonly, nullable) NSNumber *allowUntrustedSSLCertificates;

/// Specifies the maximum waiting time for response.
@property (nonatomic, readonly, nullable) NSNumber *responseTimeout;

/// Extra path component.
@property (nonatomic, readonly, nullable) NSString *URLPath;

/// Extra query parameters.
/// Vales will be converted into string using their `description` method.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id<NSObject>> *URLQuery;

/// Extra header fields, which will be appended to requests' header fields.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *headerFields;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestOptions *)source
                          with:(nullable POSHTTPRequestOptions *)target;

- (instancetype)initWithAllowedUntrustedSSLCertificates:(nullable NSNumber *)allowed
                                        responseTimeout:(nullable NSNumber *)responseTimeout
                                           headerFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields
                                               URLQuery:(nullable NSDictionary<NSString *, id<NSObject>> *)URLQuery
                                                URLPath:(nullable NSString *)URLPath NS_DESIGNATED_INITIALIZER;

POS_INIT_UNAVAILABLE

@end

#pragma mark -

///
/// The only safe way to create POSHTTPRequestOptions because it prevents code breaks
/// after adding support for new parameters in the future.
///
@interface POSHTTPRequestOptionsBuilder : NSObject

- (POSHTTPRequestOptions *)build;

- (instancetype)withPath:(nullable NSString *)path;
- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields;
- (instancetype)withQuery:(nullable NSDictionary<NSString *, id<NSObject>> *)query;
- (instancetype)withAllowedUntrustedSSLCertificates:(nullable NSNumber *)allowed;
- (instancetype)withResponseTimeout:(nullable NSNumber *)responseTimeout;

@end

NS_ASSUME_NONNULL_END
