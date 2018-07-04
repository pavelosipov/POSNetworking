//
//  NSError+POSNetworking.m
//  POSNetworking
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSError+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kPOSHTTPStatusCodeErrorKey = @"HTTPStatusCode";

NSString * const kPOSNetworkErrorCategory = @"Network";
NSString * const kPOSNetworkCancelErrorCategory = @"Cancel";
NSString * const kPOSServerErrorCategory = @"Server";

@implementation NSError (POSNetworking)

- (BOOL)pos_issuedBySSL {
    return [self.userInfo[NSUnderlyingErrorKey] p_pos_isSSLError];
}

- (nullable NSNumber *)pos_HTTPStatusCode {
    return self.userInfo[kPOSHTTPStatusCodeErrorKey];
}

- (nullable NSURL *)pos_URL {
    NSError *currentError = self;
    while (currentError) {
        NSURL *currentURL = currentError.userInfo[NSURLErrorKey];
        if (currentURL) {
            return currentURL;
        }
        currentError = currentError.userInfo[NSUnderlyingErrorKey];
    }
    return nil;
}

+ (NSError *)pos_serverErrorWithHTTPStatusCode:(NSInteger)statusCode {
    return [self pos_errorWithCategory:kPOSServerErrorCategory userInfo:@{
        kPOSHTTPStatusCodeErrorKey: @(statusCode),
        kPOSTrackableTagsKey: @[@"badcode", @(statusCode).stringValue]}];
}

+ (NSError *)pos_serverErrorWithReason:(nullable NSError *)reason format:(nullable NSString *)format, ... {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (format) {
        va_list args;
        va_start(args, format);
        userInfo[kPOSTrackableDescriptionKey] = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    userInfo[kPOSTrackableTagsKey] = @[@"response", @"unknown"];
    userInfo[NSUnderlyingErrorKey] = reason;
    return [self pos_errorWithCategory:kPOSServerErrorCategory userInfo:userInfo];
}

+ (NSError *)pos_serverErrorWithTag:(NSString *)tag format:(nullable NSString *)format, ... {
    POS_CHECK(tag);
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kPOSTrackableTagsKey] = @[@"response", tag];
    if (format) {
        va_list args;
        va_start(args, format);
        userInfo[kPOSTrackableDescriptionKey] = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return [self pos_errorWithCategory:kPOSServerErrorCategory userInfo:userInfo];
}

+ (NSError *)pos_networkErrorWithURL:(nullable NSURL *)URL reason:(nullable NSError *)reason {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[NSURLErrorKey] = URL;
    userInfo[NSUnderlyingErrorKey] = reason;
    if (reason.code == NSURLErrorCancelled) {
        return [self pos_errorWithCategory:kPOSNetworkCancelErrorCategory userInfo:userInfo];
    } else {
        userInfo[kPOSTrackableTagsKey] = [reason p_pos_networkErrorTags];
        return [self pos_errorWithCategory:kPOSNetworkErrorCategory userInfo:userInfo];
    }
}

#pragma mark - Private

- (BOOL)p_pos_isSSLError {
    switch (self.code) {
        case NSURLErrorSecureConnectionFailed:
        case NSURLErrorServerCertificateHasBadDate:
        case NSURLErrorServerCertificateUntrusted:
        case NSURLErrorServerCertificateHasUnknownRoot:
        case NSURLErrorServerCertificateNotYetValid:
        case NSURLErrorClientCertificateRejected:
        case NSURLErrorClientCertificateRequired:
        case NSURLErrorCannotLoadFromNetwork:
            return YES;
        default:
            return NO;
    }
}

- (NSArray<NSString *> *)p_pos_networkErrorTags {
    NSMutableArray<NSString *> *tags = [[NSMutableArray alloc] init];
    if ([self p_pos_isSSLError]) {
        [tags addObject:@"ssl"];
        [tags addObject:@(self.code).stringValue];
    } else {
        switch (self.code) {
            case NSURLErrorTimedOut:
                [tags addObject:@"timeout"];
                break;
            case NSURLErrorNotConnectedToInternet:
                [tags addObject:@"offline"];
                break;
            default:
                [tags addObject:@"uncategorized"];
                [tags addObject:@(self.code).stringValue];
                break;
        }
    }
    return tags;
}

@end

NS_ASSUME_NONNULL_END
