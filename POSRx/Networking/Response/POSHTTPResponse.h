//
//  POSHTTPResponse.h
//  POSRx
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents response from the server side.
@interface POSHTTPResponse : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly, nullable) NSData *data;
@property (nonatomic, readonly) NSHTTPURLResponse *metadata;

/// The designated initializer.
- (instancetype)initWithData:(nullable NSData *)data
                    metadata:(NSHTTPURLResponse *)metadata;

/// Initializer for simulating success response with status code 200.
- (instancetype)initWithData:(nullable NSData *)data;

/// Initializer for simulating response without data.
- (instancetype)initWithStatusCode:(NSInteger)statusCode;

/// Initializer for simulating response without data from specified host.
- (instancetype)initWithStatusCode:(NSInteger)statusCode hostURL:(nullable NSURL *)hostURL;

@end

NS_ASSUME_NONNULL_END
