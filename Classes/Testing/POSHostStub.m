//
//  POSHostStub.m
//  POSNetworking
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHostStub.h"
#import "POSHTTPGatewayOptions.h"
#import "POSHTTPResponse.h"
#import "POSHTTPRequestOptions.h"

#import "NSString+POSNetworking.h"
#import "NSURL+POSNetworking.h"

@interface POSHostStub ()
@property (nonatomic, copy, nullable) void (^optionsBlock)(POSHTTPGatewayOptions *options);
@end

@implementation POSHostStub

+ (instancetype)hostStub {
    return [[self alloc] initWithResponseEmitter:nil];
}

- (instancetype)initWithDataEmitter:(NSData *(^)(id<POSHTTPRequest>))emitter
                       optionsBlock:(void (^)(POSHTTPGatewayOptions *))optionsBlock {
    _optionsBlock = [optionsBlock copy];
    return [self initWithDataEmitter:emitter];
}

- (instancetype)initWithDataEmitter:(NSData *(^)(id<POSHTTPRequest>))emitter {
    POS_CHECK(emitter);
    return [self initWithResponseEmitter:^POSHTTPResponse *(id<POSHTTPRequest> request,
                                                            NSURL *hostURL,
                                                            POSHTTPRequestOptions * options) {
        NSURL *responseURL = [hostURL pos_URLByAppendingPath:options.URLPath query:options.URLQuery];
        return [[POSHTTPResponse alloc]
                initWithData:emitter(request)
                metadata:[[NSHTTPURLResponse alloc]
                          initWithURL:responseURL
                          statusCode:200
                          HTTPVersion:@"1.1"
                          headerFields:nil]];
    }];
}

- (instancetype)initWithResponseEmitter:(nullable POSHTTPResponseSimulator)emitter {
    self = [super
        initWithURL:[@"https://cloud.mail.ru" pos_URL]
        gateway:[[POSHTTPGatewayStub alloc]
            initWithRequestHandler:^RACSignal<POSHTTPResponse *> *(id<POSHTTPRequest> request,
                                                                   NSURL *hostURL,
                                                                   POSHTTPGatewayOptions * _Nullable options) {
                if (emitter) {
                    return [RACSignal return:emitter(request, hostURL, options.requestOptions)];
                } else {
                    return [RACSignal return:[[POSHTTPResponse alloc] initWithStatusCode:200]];
                }
            }]
        options:nil];
    return self;
}

- (instancetype)initWithResponseHandler:(POSHTTPGatewayStubRequestHandler)handler {
    self = [super initWithURL:[@"https://cloud.mail.ru" pos_URL]
                      gateway:[[POSHTTPGatewayStub alloc] initWithRequestHandler:handler]
                      options:nil];
    return self;
}

- (RACSignal *)pushRequest:(id<POSHTTPRequest>)request
                   options:(nullable POSHTTPGatewayOptions *)options {
    if (_optionsBlock) {
        _optionsBlock(options);
    }
    return [super pushRequest:request options:options];
}

@end
