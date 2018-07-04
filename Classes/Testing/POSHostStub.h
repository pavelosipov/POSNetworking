//
//  POSHostStub.h
//  POSNetworking
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSStaticHost.h"
#import "POSHTTPGatewayStub.h"
#import "POSHTTPResponseOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHostStub : POSStaticHost

+ (instancetype)hostStub;

- (instancetype)initWithDataEmitter:(NSData *(^)(id<POSHTTPRequest>))emitter
                       optionsBlock:(void (^)(POSHTTPGatewayOptions *))optionsBlock;

- (instancetype)initWithDataEmitter:(NSData *(^)(id<POSHTTPRequest> request))emitter;

- (instancetype)initWithResponseEmitter:(nullable POSHTTPResponseSimulator)emitter;

- (instancetype)initWithResponseHandler:(POSHTTPGatewayStubRequestHandler)handler;

- (instancetype)initWithGateway:(id<POSHTTPGateway>)gateway
                            URL:(NSURL *)URL NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
