//
//  NSString+POSNetworking.m
//  POSNetworking
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSString+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSString (POSNetworking)

- (nullable NSURL *)pos_URL {
    return [NSURL URLWithString:self];
}

- (NSString *)pos_URLEncoded {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:
        [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[] {}"].invertedSet];
}

@end

NS_ASSUME_NONNULL_END
