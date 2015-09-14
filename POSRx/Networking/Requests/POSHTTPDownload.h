//
//  POSHTTPDownload.h
//  POSRx
//
//  Created by Pavel Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

@protocol POSHTTPDownload <POSHTTPRequest>

/// Handler of the downloaded file at specified path.
@property (nonatomic, readonly, copy) void (^fileHandler)(NSURL *location);

@end

#pragma mark -

/// Request to make foreground downloads using GET HTTP method.
@interface POSHTTPDownload : POSHTTPRequest <POSHTTPDownload>

/// The designated initializer for foreground download.
- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                           destination:(void (^)(NSURL *))destination
                              progress:(void (^)(POSHTTPRequestProgress *progress))progress
                          headerFields:(NSDictionary *)headerFields;

@end

#pragma mark -

/// Mutable version of POSHTTPDownload request.
@interface POSMutableHTTPDownload : POSMutableHTTPRequest <POSHTTPDownload>

/// Handler of the downloaded file at specified path.
@property (nonatomic, copy) void (^fileHandler)(NSURL *location);

/// Creates HTTP GET request.
- (instancetype)init;

@end
