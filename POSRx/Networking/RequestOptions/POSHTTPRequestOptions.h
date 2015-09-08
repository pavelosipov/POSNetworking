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
@property (nonatomic, copy) NSNumber *allowUntrustedSSLCertificates;

/// Extra header fields, which will be appended to requests' header fields.
@property (nonatomic, copy) NSDictionary *headerFields;

/// @return New instance of options where input options override target options.
///         Nil options will not override not nil options.
- (POSHTTPRequestOptions *)merge:(POSHTTPRequestOptions *)options;

@end
