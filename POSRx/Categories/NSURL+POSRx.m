//
//  NSURL+POSRx.m
//  POSRx
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright (c) 2014 Pavel Osipov. All rights reserved.
//

#import "NSURL+POSRx.h"

@implementation NSURL (POSRx)

- (NSURL *)posrx_URLByAppendingEscapedPathComponent:(NSString *)pathComponent {
    if (!pathComponent) {
        return self;
    }
    NSString *absoluteString = [self absoluteString];
    if (![absoluteString hasSuffix:@"/"]) {
        absoluteString = [absoluteString stringByAppendingString:@"/"];
    }
    absoluteString = [absoluteString stringByAppendingString:pathComponent];
    return [NSURL URLWithString:absoluteString];
}

- (NSURL *)posrx_URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    return [NSURL URLWithString:URLString];
}

@end
