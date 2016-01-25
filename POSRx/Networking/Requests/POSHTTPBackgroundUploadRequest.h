//
//  POSHTTPBackgroundUpload.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class POSHTTPRequestProgress;

/// Protocol for making background upload requests.
@protocol POSHTTPBackgroundUploadRequest <POSHTTPRequest, NSCoding>

/// Location of uploading file in the application sandbox.
@property (nonatomic, readonly, nullable, copy) NSURL *fileLocation;

/// Additional information which will be persisted in request even between app launches.
@property (nonatomic, readonly, nullable) id<NSObject, NSCoding> userInfo;

@end

#pragma mark -

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSHTTPBackgroundUploadRequest : POSHTTPRequest <POSHTTPBackgroundUploadRequest>

/// The designated initializer.
- (instancetype)initWithMethod:(nullable POSHTTPRequestMethod *)method
                  fileLocation:(NSURL *)fileLocation
                      progress:(nullable void (^)(POSHTTPRequestProgress *progress))progress
                  headerFields:(nullable NSDictionary *)headerFields;

@end

#pragma mark -

/// Mutable version of POSHTTPBackgroundUploadRequest.
@interface POSMutableHTTPBackgroundUploadRequest : POSMutableHTTPRequest <POSHTTPBackgroundUploadRequest>

/// Location of uploading file in the application sandbox.
@property (nonatomic, nullable, copy) NSURL *fileLocation;

/// Additional information which will be persisted in request even between app launches.
@property (nonatomic, nullable) id<NSObject, NSCoding> userInfo;

/// The designated initializer.
- (instancetype)initWithFileLocation:(NSURL *)fileLocation;

@end

#pragma mark -

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSRecoveredHTTPBackgroundUploadRequest : POSHTTPBackgroundUploadRequest

/// Target host.
@property (nonatomic, readonly) NSURL *hostURL;

/// Options which were used to run that request.
@property (nonatomic, nullable, readonly) POSHTTPRequestOptions *options;

/// Notifies how many bytes were sent to remote host.
@property (nonatomic, nullable, copy) void (^uploadProgressHandler)(POSHTTPRequestProgress *progress);

/// The designated initializer.
- (instancetype)initWithRecoveredTask:(NSURLSessionUploadTask *)sessionTask;

@end

NS_ASSUME_NONNULL_END
