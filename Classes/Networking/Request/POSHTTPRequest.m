//
//  POSHTTPRequest.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"
#import "POSHTTPRequestOptions.h"
#import "NSURL+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

uint64_t const POSProgressValueUnknownUnitsCount = UINT64_MAX;

@interface POSHTTPRequest ()
@property (nonatomic, readonly) POSURLSessionTaskFactory taskFactory;
@property (nonatomic, readonly) NSString *HTTPMethod;
@end

@implementation POSHTTPRequest

@synthesize responseHandler = _responseHandler;
@synthesize options = _options;

- (instancetype)initWithHTTPMethod:(NSString *)HTTPMethod
                       taskFactory:(POSURLSessionTaskFactory)taskFactory
                   responseHandler:(POSHTTPResponseHandler)responseHandler
                           options:(nullable POSHTTPRequestOptions *)options {
    POS_CHECK(HTTPMethod);
    POS_CHECK(taskFactory);
    POS_CHECK(responseHandler);
    if (self = [super init]) {
        _HTTPMethod = [HTTPMethod copy];
        _taskFactory = [taskFactory copy];
        _responseHandler = [responseHandler copy];
        _options = options;
    }
    return self;
}

#pragma mark - POSHTTPRequest

- (nullable NSURLSessionTask *)taskWithURL:(NSURL *)hostURL
                                forGateway:(id<POSHTTPGateway>)gateway
                                   options:(nullable POSHTTPRequestOptions *)options
                                     error:(NSError **)error {
    NSURL *fullURL = [hostURL pos_URLByAppendingPath:options.URLPath query:options.URLQuery];
    NSTimeInterval responseTimeout = options.responseTimeout != nil ? options.responseTimeout.doubleValue : 30.0;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:fullURL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:responseTimeout];
    request.HTTPMethod = _HTTPMethod;
    request.HTTPBody = options.body;
    request.allHTTPHeaderFields = options.headerFields;
    return _taskFactory(request, gateway, error);
}

@end

NS_ASSUME_NONNULL_END
