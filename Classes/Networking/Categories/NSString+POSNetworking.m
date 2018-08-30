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
            [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[] <>{}"].invertedSet];
}

- (NSString *)pos_trimSymbol:(NSString *)symbol {
    NSRange range = {0, 0};
    if ([self hasPrefix:symbol]) {
        range.location = symbol.length;
        range.length = self.length - symbol.length;
    }
    if ([self hasSuffix:symbol]) {
        range.length = self.length - symbol.length - range.location;
    }
    if (range.length > 0) {
        return [self substringWithRange:range];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
