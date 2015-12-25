//
//  NSDictionary+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 18.06.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (POSRx)

/// @return Merged dictionary where target dictionary override source dictionary.
+ (NSDictionary *)posrx_merge:(NSDictionary *)sourceDictionary
                         with:(NSDictionary *)targetDictionary;

/// @brief Encodes parameters in query string of &-concatenated key-value pairs.
/// @return NSData of UTF8 encoded string.
- (NSData *)posrx_URLBody;

/// @brief Encodes parameters in query string of &-concatenated key-value pairs.
/// @return Percent escaped query string for URL.
- (NSString *)posrx_URLQuery;

@end
