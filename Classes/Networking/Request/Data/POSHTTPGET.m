//
//  MRCHTTPGET.m
//  MRCloudSDK
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Mail.Ru Group. All rights reserved.
//

#import "MRCHTTPGET.h"
#import <POSRx/NSDictionary+POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@implementation MRCHTTPGET

+ (POSHTTPRequest *)empty {
    return [POSHTTPRequest new];
}

+ (POSHTTPRequest *)path:(NSString *)path {
    POSRX_CHECK(path);
    return [self p_path:path query:nil dataHandler:nil];
}

+ (POSHTTPRequest *)path:(NSString *)path
             dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler {
    POSRX_CHECK(path);
    POSRX_CHECK(dataHandler);
    return [self p_path:path query:nil dataHandler:dataHandler];
}

+ (POSHTTPRequest *)path:(NSString *)path
                   query:(NSDictionary *)query
             dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler {
    POSRX_CHECK(path);
    POSRX_CHECK(query);
    POSRX_CHECK(dataHandler);
    return [self p_path:path query:query dataHandler:dataHandler];
}

+ (POSHTTPRequest *)path:(NSString *)path query:(NSDictionary *)query {
    POSRX_CHECK(path);
    POSRX_CHECK(query);
    return [self p_path:path query:query dataHandler:nil];
}

+ (POSHTTPRequest *)query:(NSDictionary *)query {
    POSRX_CHECK(query);
    return [self p_path:nil query:query dataHandler:nil];
}

+ (POSHTTPRequest *)query:(NSDictionary *)query
              dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler {
    POSRX_CHECK(query);
    POSRX_CHECK(dataHandler);
    return [self p_path:nil query:query dataHandler:dataHandler];
}

+ (POSHTTPRequest *)dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler {
    POSRX_CHECK(dataHandler);
    return [self p_path:nil query:nil dataHandler:dataHandler];
}

+ (POSHTTPRequest *)method:(POSHTTPRequestMethod *)method dataHandler:(MRCHTTPRequestResponseDataHandler)dataHandler {
    POSRX_CHECK(method);
    POSRX_CHECK(dataHandler);
    return [self p_method:method dataHandler:dataHandler];
}

+ (POSHTTPRequest *)p_path:(nullable NSString *)path
                     query:(nullable NSDictionary *)query
               dataHandler:(nullable MRCHTTPRequestResponseDataHandler)dataHandler {
    return [self p_method:[POSHTTPRequestMethod path:path query:query] dataHandler:dataHandler];
}

+ (POSHTTPRequest *)p_method:(nullable POSHTTPRequestMethod *)method
                 dataHandler:(nullable MRCHTTPRequestResponseDataHandler)dataHandler {
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypeGET
                               method:method
                               body:nil
                               headerFields:nil];
    request.mrc_responseDataHandler = dataHandler;
    return request;
}

@end

NS_ASSUME_NONNULL_END
