//
//  POSHTTPUploadRequest.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPUploadRequest.h"
#import "NSException+POSRx.h"

@interface POSHTTPUploadRequest ()
@property (nonatomic, copy) NSInputStream *(^bodyStreamBuilder)();
@end

@implementation POSHTTPUploadRequest

POSRX_DEADLY_INITIALIZER(initWithType:(POSHTTPRequestType)type
                         endpointMethod:(NSString *)endpointMethod
                         body:(NSData *)body
                         headerFields:(NSDictionary *)headerFields)

- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                     bodyStreamBuilder:(NSInputStream *(^)())bodyStreamBuilder
                          headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(bodyStreamBuilder);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                    endpointMethod:endpointMethod
                              body:nil
                      headerFields:headerFields]) {
        _bodyStreamBuilder = [bodyStreamBuilder copy];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options {
    NSMutableURLRequest *request = [super requestWithURL:hostURL options:options];
    request.HTTPBodyStream = _bodyStreamBuilder();
    return request;
}

@end

#pragma mark -

@implementation POSMutableHTTPUploadRequest

- (instancetype)init {
    return [self initWithType:POSHTTPRequestTypePUT
               endpointMethod:nil
                         body:nil
                 headerFields:nil];
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)hostURL options:(POSHTTPRequestOptions *)options {
    NSMutableURLRequest *request = [super requestWithURL:hostURL options:options];
    if (_bodyStreamBuilder) {
        request.HTTPBodyStream = _bodyStreamBuilder();
    }
    return request;
}

@end
