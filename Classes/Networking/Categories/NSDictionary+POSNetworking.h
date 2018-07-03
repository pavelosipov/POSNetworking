//
//  NSDictionary+POSNetworking.h
//  POSNetworking
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (POSNetworking)

/// @brief  Encodes parameters in query string of &-concatenated key-value pairs.
/// @return NSData of UTF8 encoded string.
- (NSData *)pos_URLQueryBody;

/// @brief  Encodes parameters in JSON.
/// @return NSData of JSON encoded dictionary.
- (NSData *)pos_URLJSONBody;

/// @brief  Encodes parameters in query string of &-concatenated key-value pairs.
/// @return Percent escaped query string for URL.
- (NSString *)pos_URLQuery;

/// @brief Encodes parameters in query string of &-concatenated key-value pairs.
- (NSString *)pos_URLQueryEncoded:(BOOL)encoded;

/// @return Merged dictionary where target dictionary override source dictionary.
+ (nullable NSDictionary *)pos_merge:(nullable NSDictionary *)source
                                with:(nullable NSDictionary *)target;

@end

NS_ASSUME_NONNULL_END
