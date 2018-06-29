//
//  POSHTTPResponse.h
//  POSNetworking
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents response from the server side.
@interface POSHTTPResponse : NSObject

@property (nonatomic, readonly, nullable) NSData *data;
@property (nonatomic, readonly) NSHTTPURLResponse *metadata;

/// Initializer for simulating success response with status code 200.
- (instancetype)initWithData:(nullable NSData *)data;

/// Initializer for simulating response without data.
- (instancetype)initWithStatusCode:(NSInteger)statusCode;

/// Initializer for simulating response without data from specified host.
- (instancetype)initWithStatusCode:(NSInteger)statusCode hostURL:(nullable NSURL *)hostURL;

/// The designated initializer.
- (instancetype)initWithData:(nullable NSData *)data
                    metadata:(NSHTTPURLResponse *)metadata NS_DESIGNATED_INITIALIZER;

POS_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
