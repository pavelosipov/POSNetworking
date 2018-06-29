//
//  NSError+POSNetworking.h
//  POSNetworking
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (POSNetworking)

- (NSError *)pos_errorWithURL:(nullable NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
