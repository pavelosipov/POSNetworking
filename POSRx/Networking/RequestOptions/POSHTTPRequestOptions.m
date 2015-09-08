//
//  POSHTTPRequestOptions.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestOptions.h"

@implementation POSHTTPRequestOptions

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
    typeof(self) clone = [[[self class] allocWithZone:zone] init];
    clone.allowUntrustedSSLCertificates = _allowUntrustedSSLCertificates;
    clone.headerFields = _headerFields;
    return clone;
}

- (POSHTTPRequestOptions *)merge:(POSHTTPRequestOptions *)options {
    POSHTTPRequestOptions *mergedOptions = [self copy];
    if (options.allowUntrustedSSLCertificates) {
        mergedOptions.allowUntrustedSSLCertificates = options.allowUntrustedSSLCertificates;
    }
    if (options.headerFields) {
        NSMutableDictionary *headerFields = [mergedOptions.headerFields mutableCopy];
        [headerFields addEntriesFromDictionary:options.headerFields];
        mergedOptions.headerFields = headerFields;
    }
    return mergedOptions;
}

@end
