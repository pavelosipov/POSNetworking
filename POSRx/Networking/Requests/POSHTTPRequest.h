//
//  POSHTTPRequest.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POSHTTPRequestOptions;

/// Available types of HTTP requests.
typedef NS_ENUM(NSInteger, POSHTTPRequestType) {
    POSHTTPRequestTypeGET,
    POSHTTPRequestTypeHEAD,
    POSHTTPRequestTypePOST,
    POSHTTPRequestTypePUT
};

/// Represents request to remote server.
@protocol POSHTTPRequest <NSObject>

/// Type of HTTP request.
@property (nonatomic, readonly) POSHTTPRequestType type;

/// Method which will be appended to host's base URL (for ex. "users/?sort=ASC"). May be nil.
@property (nonatomic, readonly) NSString *endpointMethod;

/// Request's body. May be nil.
@property (nonatomic, readonly) NSData *body;

/// Request's headers, which will be appedned to or override default host headers. May be nil.
@property (nonatomic, readonly) NSDictionary *headerFields;

@end

#pragma mark -

/// Helper class to create standard HTTP requests.
@interface POSHTTPRequest : NSObject <POSHTTPRequest, NSCoding>

/// The designated initializer which init request as GET request
/// without any custom values for properties.
- (instancetype)init;

/// The designated initializer.
- (instancetype)initWithType:(POSHTTPRequestType)type
              endpointMethod:(NSString *)endpointMethod
                        body:(NSData *)body
                headerFields:(NSDictionary *)headerFields;
@end

#pragma mark -

/// Mutable version of POSHTTPRequest.
@interface POSMutableHTTPRequest : POSHTTPRequest

/// Type of HTTP request.
@property (nonatomic) POSHTTPRequestType type;

/// Method which will be appended to host's base URL (for ex. "users/?sort=ASC"). May be nil.
@property (nonatomic, copy) NSString *endpointMethod;

/// Request's body. May be nil.
@property (nonatomic, copy) NSData *body;

/// Request's headers, which will be appedned to or override default host headers. May be nil.
@property (nonatomic, copy) NSDictionary *headerFields;

@end
