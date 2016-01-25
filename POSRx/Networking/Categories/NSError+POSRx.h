//
//  NSError+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (POSRx)

- (NSError *)errorWithURL:(nullable NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
