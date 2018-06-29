//
//  POSHTTPRequestPacketOptions.h
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
@interface POSHTTPRequestPacketOptions : NSObject

/// YES value indicates, that HTTP request may be sent to hosts
/// with untrusted SSL certificates (for ex. self-signed).
/// May be nil if default value should be used.
@property (nonatomic, readonly, nullable) NSNumber *allowUntrustedSSLCertificates;

/// Specifies the maximum waiting time for response.
@property (nonatomic, readonly, nullable) NSNumber *responseTimeout;

/// Extra header fields, which will be appended to requests' header fields.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *headerFields;

/// Extra query parameters, which will be appended to requests' query parameters.
/// Vales will be converted into string using their `description` method.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id<NSObject>> *URLQuery;

/// @return New instance of options where target options override source options.
///         Nil options will not override not nil options.
+ (nullable instancetype)merge:(nullable POSHTTPRequestPacketOptions *)source
                          with:(nullable POSHTTPRequestPacketOptions *)target;

@end

#pragma mark -

///
/// The only safe way to create POSHTTPRequestPacketOptions because it prevents code breaks
/// after adding support for new parameters in the future.
///
@interface POSHTTPRequestPacketOptionsBuilder : NSObject

- (POSHTTPRequestPacketOptions *)build;

- (instancetype)withHeaderFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields;
- (instancetype)withURLQuery:(nullable NSDictionary<NSString *, id<NSObject>> *)URLQuery;
- (instancetype)withAllowedUntrustedSSLCertificates:(nullable NSNumber *)allowed;
- (instancetype)withResponseTimeout:(nullable NSNumber *)responseTimeout;

@end

NS_ASSUME_NONNULL_END
