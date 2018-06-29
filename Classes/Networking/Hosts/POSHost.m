//
//  MRCHost.m
//  MRCloudSDK
//
//  Created by Pavel Osipov on 22.09.15.
//  Copyright (c) 2015 Mail.Ru Group. All rights reserved.
//

#import "MRCHost.h"
#import "MRCTracker.h"
#import "POSHTTPRequest+MRCSDK.h"
#import "NSError+MRCSDK.h"
#import "MRCLog.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kMRCHostParamKey = @"h";

@interface MRCHost ()
@property (nonatomic) NSString *ID;
@property (nonatomic) id<POSHTTPGateway> gateway;
@property (nonatomic, nullable) id<MRCTracker> tracker;
@end

@implementation MRCHost

- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<MRCTracker>)tracker {
    POSRX_CHECK(ID.length > 0);
    POSRX_CHECK(gateway);
    if (self = [super initWithScheduler:gateway.scheduler]) {
        _ID = [ID copy];
        _gateway = gateway;
        _tracker = tracker;
    }
    return self;
}

- (nullable NSURL *)URL {
    POSRX_THROW_NOT_IMPLEMENTED;
    return nil;
}

- (RACSignal *)fetchURL {
    return [self fetchURLWithMethod:nil];
}

- (RACSignal *)fetchURLWithMethod:(nullable POSHTTPRequestMethod *)method {
    POSRX_CHECK(self.URL);
    return [RACSignal return:[self.URL posrx_URLByAppendingMethod:method]];
}

- (RACSignal *)pushRequest:(POSHTTPRequest *)request {
    return [self pushRequest:request options:nil];
}

- (RACSignal *)pushRequest:(POSHTTPRequest *)request
                   options:(nullable POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    POSRX_CHECK(self.URL);
    @weakify(self);
    return [[[[[[_gateway
        taskForRequest:request toHost:self.URL options:options]
        execute]
        takeUntil:self.rac_willDeallocSignal]
        catch:^RACSignal *(NSError *error) {
            if (error.mrc_URL) {
                return [RACSignal error:[NSError mrc_networkErrorWithReason:error]];
            } else {
                return [RACSignal error:[NSError mrc_systemErrorWithReason:error]];
            }
        }]
        flattenMap:^RACSignal *(POSHTTPResponse *response) {
            @try {
                NSError *error = nil;
                id parsedResponse = response;
                if (request.mrc_responseHandler) {
                    parsedResponse = request.mrc_responseHandler(response, &error);
                }
                if (error) {
                    return [RACSignal error:error];
                }
                if (parsedResponse) {
                    return [RACSignal return:parsedResponse];
                }
                return [RACSignal empty];
            } @catch (NSException *exception) {
                MRCLogError(@"[EXCEPTION] name:%@, userInfo:%@", exception.name, exception.userInfo);
                return [RACSignal error:[NSError mrc_serverErrorWithTag:@"exception" format:exception.reason]];
            }
        }]
        doError:^(NSError *error) {
            @strongify(self);
            NSError *hostError = [NSError mrc_hostErrorWithHostID:self.ID hostURL:self.URL reason:error];
            MRCLogError(@"[%@] %@", self.ID, hostError);
            [self.tracker track:hostError];
        }];
}

@end

#pragma mark -

@implementation NSError (MRCHost)

+ (NSString *)mrc_hostErrorCategory {
    return @"hosts";
}

+ (NSError *)mrc_hostErrorWithHostID:(NSString *)hostID
                             hostURL:(nullable NSURL *)hostURL
                              reason:(nullable NSError *)reason {
    POSRX_CHECK(hostID);
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kMRCTrackableTagsKey] = @[hostID];
    if (hostURL.host) {
        userInfo[NSURLErrorKey] = hostURL;
        userInfo[kMRCTrackableParamsKey] = @{kMRCHostParamKey: hostURL.host};
    }
    userInfo[NSUnderlyingErrorKey] = reason;
    return [self mrc_errorWithCategory:self.mrc_hostErrorCategory userInfo:userInfo];
}

@end

NS_ASSUME_NONNULL_END
