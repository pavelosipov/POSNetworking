//
//  NSString+POSRx.h
//  POSRx
//
//  Created by Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (POSRx)

/// Creates URL from that string.
- (nullable NSURL *)posrx_URL;

/// Creates percent escaped string.
- (NSString *)posrx_percentEscaped;

/// Creates percent escaped string.
- (NSString *)posrx_percentEscapedWithEscapingSymbols:(NSString *)symbols;

@end

NS_ASSUME_NONNULL_END
