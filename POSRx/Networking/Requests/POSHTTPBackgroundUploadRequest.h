//
//  POSHTTPBackgroundUploadRequest.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

/// Protocol for making background upload requests.
@protocol POSHTTPBackgroundUploadRequest <POSHTTPRequest, NSCoding>

/// Location of uploading file in the application sandbox.
@property (nonatomic, readonly, copy) NSURL *fileLocation;

@end

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSHTTPBackgroundUploadRequest : POSHTTPRequest <POSHTTPBackgroundUploadRequest>

/// The designated initializer.
- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                          fileLocation:(NSURL *)fileLocation
                          headerFields:(NSDictionary *)headerFields;

@end

/// Mutable version of POSHTTPBackgroundUploadRequest.
@interface POSMutableHTTPBackgroundUploadRequest : POSMutableHTTPRequest <POSHTTPBackgroundUploadRequest>

/// Location of uploading file in the application sandbox.
@property (nonatomic, copy) NSURL *fileLocation;

/// The designated initializer.
- (instancetype)initFileLocation:(NSURL *)fileLocation;

@end
