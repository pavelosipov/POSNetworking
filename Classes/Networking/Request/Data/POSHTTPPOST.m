//
//  MRCHTTPPOST.m
//  MRCloudSDK
//
//  Created by Osipov on 15/04/16.
//  Copyright © 2016 Mail.Ru Group. All rights reserved.
//

#import "MRCHTTPPOST.h"
#import <POSJSONParsing/POSJSONParsing.h>

NS_ASSUME_NONNULL_BEGIN

@implementation MRCHTTPPOST

+ (POSHTTPRequest *)body:(NSData *)body dataHandler:(MRCHTTPRequestResponseDataHandler)handler {
    return [self p_path:nil body:body dataHandler:handler];
}

+ (POSHTTPRequest *)namedParams:(NSDictionary *)params dataHandler:(MRCHTTPRequestResponseDataHandler)handler {
    POSRX_CHECK(params);
    POSRX_CHECK(handler);
    return [self p_path:nil namedParams:params dataHandler:handler];
}

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params
             dataHandler:(MRCHTTPRequestResponseDataHandler)handler {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSRX_CHECK(handler);
    return [self p_path:path namedParams:params dataHandler:handler];
}

+ (POSHTTPRequest *)path:(NSString *)path JSONParams:(NSDictionary *)params {
    return [self path:path JSONParams:params query:nil];
}

+ (POSHTTPRequest *)path:(NSString *)path JSONParams:(NSDictionary *)params query:(nullable NSDictionary *)query {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:[POSHTTPRequestMethod path:path query:query]
                               body:[params posrx_URLJSONBody]
                               headerFields:@{@"content-type": @"application/json"}];
    return request;
}

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(NSDictionary *)params
            JSONResponse:(MRCHTTPRequestResponseJSONMapHandler)handler {
    val request = [self path:path JSONParams:params query:nil];
    request.mrc_responseDataHandler = ^id(NSData *responseData, NSError **error) {
        return handler([[POSJSONMap alloc] initWithData:responseData], error);
    };
    return request;
}

+ (POSHTTPRequest *)path:(NSString *)path namedParams:(NSDictionary *)params {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:[POSHTTPRequestMethod path:path query:nil]
                               body:[params posrx_URLQueryBody]
                               headerFields:@{@"content-type": @"application/json"}];
    return request;
}

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params
         responseHandler:(MRCHTTPRequestResponseHandler)handler {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSRX_CHECK(handler);
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:[POSHTTPRequestMethod path:path query:nil]
                               body:[params posrx_URLQueryBody]
                               headerFields:nil];
    if (handler) {
        request.mrc_responseHandler = handler;
    }
    return request;
}

#pragma mark Private

+ (POSHTTPRequest *)p_path:(nullable NSString *)path
               namedParams:(nullable NSDictionary *)params
               dataHandler:(nullable MRCHTTPRequestResponseDataHandler)handler {
    return [self p_path:path body:[params posrx_URLQueryBody] dataHandler:handler];
}

+ (POSHTTPRequest *)p_path:(nullable NSString *)path
                      body:(nullable NSData *)body
               dataHandler:(nullable MRCHTTPRequestResponseDataHandler)handler {
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:(path ? [POSHTTPRequestMethod path:path query:nil] : nil)
                               body:body
                               headerFields:nil];
    if (handler) {
        request.mrc_responseDataHandler = handler;
    }
    return request;
}

@end

NS_ASSUME_NONNULL_END
