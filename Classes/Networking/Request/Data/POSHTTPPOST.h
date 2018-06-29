//
//  MRCHTTPPOST.h
//  MRCloudSDK
//
//  Created by Osipov on 15/04/16.
//  Copyright © 2016 Mail.Ru Group. All rights reserved.
//

#import "POSHTTPRequest+MRCSDK.h"

NS_ASSUME_NONNULL_BEGIN

@class POSJSONMap;

typedef __nullable id (^MRCHTTPRequestResponseJSONMapHandler)(POSJSONMap *JSONMap, NSError **error);

@interface MRCHTTPPOST : NSObject

+ (POSHTTPRequest *)body:(NSData *)body
             dataHandler:(MRCHTTPRequestResponseDataHandler)handler;

+ (POSHTTPRequest *)namedParams:(NSDictionary *)params
                    dataHandler:(MRCHTTPRequestResponseDataHandler)handler;

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(NSDictionary *)params;

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(NSDictionary *)params
                   query:(nullable NSDictionary *)query;

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(NSDictionary *)params
            JSONResponse:(MRCHTTPRequestResponseJSONMapHandler)handler;

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params;

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params
             dataHandler:(MRCHTTPRequestResponseDataHandler)handler;

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params
         responseHandler:(MRCHTTPRequestResponseHandler)handler;

@end

NS_ASSUME_NONNULL_END
