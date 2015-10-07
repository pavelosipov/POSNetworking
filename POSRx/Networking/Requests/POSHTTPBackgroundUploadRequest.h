//
//  POSHTTPBackgroundUpload.h
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

@class POSHTTPRequestProgress;

/// Protocol for making background upload requests.
@protocol POSHTTPBackgroundUploadRequest <POSHTTPRequest, NSCoding>

/// Location of uploading file in the application sandbox.
@property (nonatomic, readonly, copy) NSURL *fileLocation;

/// Additional information which will be persisted in request even between app launches.
@property (nonatomic, readonly) id<NSObject, NSCoding> userInfo;

@end

#pragma mark -

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSHTTPBackgroundUploadRequest : POSHTTPRequest <POSHTTPBackgroundUploadRequest>

/// The designated initializer.
- (instancetype)initWithMethod:(POSHTTPRequestMethod *)method
                  fileLocation:(NSURL *)fileLocation
                      progress:(void (^)(POSHTTPRequestProgress *progress))progress
                  headerFields:(NSDictionary *)headerFields;

@end

#pragma mark -

/// Mutable version of POSHTTPBackgroundUploadRequest.
@interface POSMutableHTTPBackgroundUploadRequest : POSMutableHTTPRequest <POSHTTPBackgroundUploadRequest>

/// Location of uploading file in the application sandbox.
@property (nonatomic, copy) NSURL *fileLocation;

/// Additional information which will be persisted in request even between app launches.
@property (nonatomic) id<NSObject, NSCoding> userInfo;

/// The designated initializer.
- (instancetype)initWithFileLocation:(NSURL *)fileLocation;

@end

#pragma mark -

/// Request to make background uploads using nsurlsessiond deamon.
@interface POSRecoveredHTTPBackgroundUploadRequest : POSHTTPBackgroundUploadRequest

/// Target host.
@property (nonatomic, readonly) NSURL *hostURL;

/// Options which were used to run that request.
@property (nonatomic, readonly) POSHTTPRequestOptions *options;

/// Notifies how many bytes were sent to remote host.
@property (nonatomic, copy) void (^uploadProgressHandler)(POSHTTPRequestProgress *progress);

/// The designated initializer.
- (instancetype)initWithRecoveredTask:(NSURLSessionUploadTask *)sessionTask;

@end
