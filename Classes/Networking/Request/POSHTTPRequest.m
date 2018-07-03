//
//  POSHTTPRequest.m
//  POSNetworking
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

uint64_t const POSProgressValueUnknownUnitsCount = UINT64_MAX;

@implementation POSHTTPRequest

@synthesize taskFactory = _taskFactory;
@synthesize responseHandler = _responseHandler;
@synthesize options = _options;

- (instancetype)initWithTaskFactory:(POSHTTPRequestTaskFactory)taskFactory
                    responseHandler:(POSHTTPResponseHandler)responseHandler
                            options:(nullable POSHTTPRequestOptions *)options {
    POS_CHECK(taskFactory);
    POS_CHECK(responseHandler);
    if (self = [super init]) {
        _taskFactory = [taskFactory copy];
        _responseHandler = [responseHandler copy];
        _options = options;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
