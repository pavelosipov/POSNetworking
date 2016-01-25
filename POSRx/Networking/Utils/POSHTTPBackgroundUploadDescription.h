//
//  POSHTTPBackgroundUploadDescription.h
//  POSRx
//
//  Created by Pavel Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSContracts.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSHTTPBackgroundUploadRequest;
@class POSHTTPRequestOptions;

@interface POSHTTPBackgroundUploadDescription : NSObject <NSCoding>

@property (nonatomic, readonly) id<POSHTTPBackgroundUploadRequest> request;
@property (nonatomic, readonly) NSURL *hostURL;
@property (nonatomic, readonly, nullable) POSHTTPRequestOptions *options;

- (instancetype)initWithRequest:(id<POSHTTPBackgroundUploadRequest>)request
                        hostURL:(NSURL *)hostURL
                        options:(nullable POSHTTPRequestOptions *)options;

+ (instancetype)fromString:(NSString *)description;
- (NSString *)asString;

POSRX_INIT_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
