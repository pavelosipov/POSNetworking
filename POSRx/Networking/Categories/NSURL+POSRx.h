//
//  NSURL+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright (c) 2014 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (POSRx)

- (nullable NSURL *)posrx_URLByAppendingEscapedPathComponent:(nullable NSString *)pathComponent;
- (nullable NSURL *)posrx_URLByAppendingQueryString:(nullable NSString *)queryString;

@end

NS_ASSUME_NONNULL_END
