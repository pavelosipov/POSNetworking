//
//  NSString+POSRx.m
//  POSRx
//
//  Created by Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSString+POSRx.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSString (POSRx)

- (nullable NSURL *)posrx_URL {
    return [NSURL URLWithString:self];
}

- (NSString *)posrx_percentEscaped {
    return [self posrx_percentEscapedWithEscapingSymbols:@"!*'();:@&=+$,/?%#[]"];
}

- (NSString *)posrx_percentEscapedWithEscapingSymbols:(NSString *)symbols {
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(
                kCFAllocatorDefault,
                (CFStringRef)self,
                NULL,
                (CFStringRef)symbols,
                kCFStringEncodingUTF8);
}

- (nullable NSString *)posrx_percentDecoded {
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                kCFAllocatorDefault,
                (CFStringRef)self,
                CFSTR(""),
                kCFStringEncodingUTF8);
}

@end

NS_ASSUME_NONNULL_END
