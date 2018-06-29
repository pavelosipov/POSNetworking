//
//  POSHTTPRequest+MRCSDK.m
//  MRCloudSDK
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Mail.Ru Group. All rights reserved.
//

#import "POSHTTPRequest+MRCSDK.h"
#import "NSError+MRCSDK.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - POSHTTPRequest (MRCSDK)

static char kMRCHTTPRequestResponseHandlerKey;
static char kMRCHTTPRequestResponseDataHandlerKey;
static char kMRCHTTPRequestResponseMetadataHandlerKey;

@implementation POSHTTPRequest (MRCSDK)

- (nullable MRCHTTPRequestResponseHandler)mrc_responseHandler {
    MRCHTTPRequestResponseHandler handler = objc_getAssociatedObject(self, &kMRCHTTPRequestResponseHandlerKey);
    if (handler) {
        return handler;
    }
    @weakify(self);
    return [^id(POSHTTPResponse *response, NSError **error) {
        @strongify(self);
        MRCHTTPRequestResponseMetadataHandler metadataHandler = self.mrc_responseMetadataHandler;
        if (!metadataHandler(response.metadata, error)) {
            return nil;
        }
        if (self.mrc_responseDataHandler) {
            if (!response.data) {
                MRCAssignError(error, [NSError mrc_serverErrorWithFormat:@"No data in reponse."]);
                return nil;
            }
            return self.mrc_responseDataHandler(response.data, error);
        }
        return response;
    } copy];
}

- (nullable MRCHTTPRequestResponseMetadataHandler)mrc_responseMetadataHandler {
    MRCHTTPRequestResponseMetadataHandler handler = objc_getAssociatedObject(self, &kMRCHTTPRequestResponseMetadataHandlerKey);
    if (handler) {
        return handler;
    }
    return [^BOOL(NSHTTPURLResponse *metadata, NSError **error) {
        if (![metadata mrc_contains2XXStatusCode]) {
            MRCAssignError(error, [NSError mrc_serverErrorWithHTTPStatusCode:metadata.statusCode]);
            return NO;
        }
        return YES;
    } copy];
}

- (void)mrc_setResponseMetadataHandler:(nullable MRCHTTPRequestResponseMetadataHandler)handler {
    objc_setAssociatedObject(self, &kMRCHTTPRequestResponseMetadataHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)mrc_setResponseHandler:(nullable MRCHTTPRequestResponseHandler)handler {
    objc_setAssociatedObject(self, &kMRCHTTPRequestResponseHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable MRCHTTPRequestResponseDataHandler)mrc_responseDataHandler {
    return objc_getAssociatedObject(self, &kMRCHTTPRequestResponseDataHandlerKey);
}

- (void)mrc_setResponseDataHandler:(nullable MRCHTTPRequestResponseDataHandler)handler {
    objc_setAssociatedObject(self, &kMRCHTTPRequestResponseDataHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark - NSHTTPURLResponse (MRCSDK)

@implementation NSHTTPURLResponse (MRCSDK)

- (BOOL)mrc_contains2XXStatusCode {
    return self.statusCode / 100 == 2;
}

@end

#pragma mark -

@implementation NSNumber (MRCSDK)

- (BOOL)mrc_contains2XXStatusCode {
    return self.integerValue / 100 == 2;
}

@end

NS_ASSUME_NONNULL_END
