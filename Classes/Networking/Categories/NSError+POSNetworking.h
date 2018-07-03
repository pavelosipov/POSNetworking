//
//  NSError+POSNetworking.h
//  POSNetworking
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const kPOSNetworkErrorCategory;
FOUNDATION_EXTERN NSString * const kPOSNetworkCancelErrorCategory;
FOUNDATION_EXTERN NSString * const kPOSServerErrorCategory;

@interface NSError (POSNetworking)

@property (nonatomic, readonly, nullable) NSURL *pos_URL;
@property (nonatomic, readonly, nullable) NSNumber *pos_HTTPStatusCode;
@property (nonatomic, readonly) BOOL pos_issuedBySSL;

/// Factory method for errors issued by network connection.
+ (NSError *)pos_networkErrorWithURL:(nullable NSURL *)URL reason:(nullable NSError *)reason;

/// Factory method for errors issued by some unexpected server behaviour.
+ (NSError *)pos_serverErrorWithTag:(NSString *)tag format:(nullable NSString *)format, ...;

/// Factory method for errors issued by bad responses from API endpoints.
+ (NSError *)pos_serverErrorWithHTTPStatusCode:(NSInteger)statusCode;

@end

NS_ASSUME_NONNULL_END
