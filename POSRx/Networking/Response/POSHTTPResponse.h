//
//  POSHTTPResponse.h
//  POSRx
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Represents response from the server side.
@interface POSHTTPResponse : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSHTTPURLResponse *metadata;

/// The designated initializer.
- (instancetype)initWithData:(NSData *)data
                    metadata:(NSHTTPURLResponse *)metadata;
/// Initializer for simulating success response with status code 200.
- (instancetype)initWithData:(NSData *)data;
/// Initializer for simulating failure response without data.
- (instancetype)initWithStatusCode:(NSInteger)statusCode;

@end
