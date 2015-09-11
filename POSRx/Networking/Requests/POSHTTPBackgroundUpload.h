//
//  POSHTTPBackgroundUpload.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

@class POSHTTPTaskProgress;

/// Protocol for making background upload requests.
@protocol POSHTTPBackgroundUpload <POSHTTPRequest, NSCoding>

/// Location of uploading file in the application sandbox.
@property (nonatomic, readonly, copy) NSURL *fileLocation;

/// Additional information which will be persisted in request even between app launches.
@property (nonatomic, readonly) id<NSObject, NSCoding> userInfo;

/// Uploading progress handler.
@property (nonatomic, readonly, copy) void (^progress)(POSHTTPTaskProgress *progress);

@end

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSHTTPBackgroundUpload : POSHTTPRequest <POSHTTPBackgroundUpload>

/// The designated initializer.
- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                          fileLocation:(NSURL *)fileLocation
                              progress:(void (^)(POSHTTPTaskProgress *progress))progress
                          headerFields:(NSDictionary *)headerFields;

@end

/// Mutable version of POSHTTPBackgroundUploadRequest.
@interface POSMutableHTTPBackgroundUpload : POSMutableHTTPRequest <POSHTTPBackgroundUpload>

/// Location of uploading file in the application sandbox.
@property (nonatomic, copy) NSURL *fileLocation;

/// Additional information which will be persisted in request even between app launches.
@property (nonatomic) id<NSObject, NSCoding> userInfo;

/// Uploading progress handler.
@property (nonatomic, copy) void (^progress)(POSHTTPTaskProgress *progress);

/// The designated initializer.
- (instancetype)initFileLocation:(NSURL *)fileLocation;

@end

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSRecoveredHTTPBackgroundUpload : POSHTTPBackgroundUpload

/// Uploading progress handler.
@property (nonatomic, copy) void (^progress)(POSHTTPTaskProgress *progress);

/// The designated initializer.
- (instancetype)initWithRecoveredTask:(NSURLSessionUploadTask *)sessionTask;

@end
