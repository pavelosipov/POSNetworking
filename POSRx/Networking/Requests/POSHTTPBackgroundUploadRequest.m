//
//  POSHTTPBackgroundUploadRequest.m
//  POSRx
//
//  Created by Pavel Osipov on 29.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPBackgroundUploadRequest.h"
#import "NSException+POSRx.h"
#import <objc/runtime.h>

static char kPOSFileLocationKey;

@interface POSHTTPRequest (POSHTTPBackgroundUploadRequest) <POSHTTPRequest>
@property (nonatomic, copy) NSURL *fileLocation;
@end

@implementation POSHTTPRequest (POSHTTPBackgroundUploadRequest)

- (NSURL *)fileLocation {
    return objc_getAssociatedObject(self, &kPOSFileLocationKey);
}

- (void)setFileLocation:(NSURL *)fileLocation {
    POSRX_CHECK(fileLocation);
    objc_setAssociatedObject(self, &kPOSFileLocationKey, fileLocation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)posrx_decodeWithCoder:(NSCoder *)aDecoder {
    NSURL *fileLocation = [aDecoder decodeObjectForKey:@"fileLocation"];;
    NSParameterAssert(fileLocation);
    self.fileLocation = fileLocation;
}

- (void)posrx_encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fileLocation forKey:@"fileLocation"];
}

@end

#pragma mark -

@implementation POSHTTPBackgroundUploadRequest
@dynamic fileLocation;

- (instancetype)initWithEndpointMethod:(NSString *)endpointMethod
                          fileLocation:(NSURL *)fileLocation
                          headerFields:(NSDictionary *)headerFields {
    POSRX_CHECK(fileLocation);
    if (self = [super initWithType:POSHTTPRequestTypePUT
                    endpointMethod:endpointMethod
                              body:nil
                      headerFields:headerFields]) {
        self.fileLocation = fileLocation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self posrx_decodeWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [self posrx_encodeWithCoder:aCoder];
}

@end

#pragma mark -

@implementation POSMutableHTTPBackgroundUploadRequest
@dynamic fileLocation;

- (instancetype)initFileLocation:(NSURL *)fileLocation {
    POSRX_CHECK(fileLocation);
    if (self = [super init]) {
        self.fileLocation = fileLocation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self posrx_decodeWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [self posrx_encodeWithCoder:aCoder];
}

@end

