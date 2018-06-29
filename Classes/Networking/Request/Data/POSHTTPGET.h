//
//  MRCHTTPGET.h
//  MRCloudSDK
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Mail.Ru Group. All rights reserved.
//

#import "POSHTTPRequest+MRCSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// Group of factory methods to create HTTP GET requests.
@interface MRCHTTPGET : NSObject

+ (POSHTTPRequest *)empty;

+ (POSHTTPRequest *)path:(NSString *)path;

+ (POSHTTPRequest *)path:(NSString *)path query:(NSDictionary *)query;

+ (POSHTTPRequest *)path:(NSString *)path dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)path:(NSString *)path query:(NSDictionary *)query dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)query:(NSDictionary *)query;

+ (POSHTTPRequest *)query:(NSDictionary *)query dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)method:(POSHTTPRequestMethod *)method dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler;

@end

NS_ASSUME_NONNULL_END
