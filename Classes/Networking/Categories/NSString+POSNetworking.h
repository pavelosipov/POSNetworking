//
//  NSString+POSRx.h
//  POSNetworking
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (POSNetworking)

- (nullable NSURL *)pos_URL;

- (NSString *)pos_URLEncoded;

- (NSString *)pos_trimSymbol:(NSString *)symbol;

@end

NS_ASSUME_NONNULL_END
