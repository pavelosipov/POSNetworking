//
//  POSHTTPBackgroundUploadDescription.h
//  POSRx
//
//  Created by Pavel Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol POSHTTPBackgroundUpload;
@class POSHTTPRequestOptions;

@interface POSHTTPBackgroundUploadDescription : NSObject <NSCoding>

@property (nonatomic) id<POSHTTPBackgroundUpload> request;
@property (nonatomic) NSURL *hostURL;
@property (nonatomic) POSHTTPRequestOptions *options;
@property (nonatomic) id<NSObject,NSCoding> userInfo;

+ (instancetype)fromString:(NSString *)description;
- (NSString *)asString;

@end

