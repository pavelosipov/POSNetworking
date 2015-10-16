//
//  NSURL+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright (c) 2014 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (POSRx)

- (NSURL *)posrx_URLByAppendingEscapedPathComponent:(NSString *)pathComponent;
- (NSURL *)posrx_URLByAppendingQueryString:(NSString *)queryString;

@end
