//
//  NSHTTPURLResponse+POSNetworking.h
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPURLResponse (POSNetworking)

- (BOOL)pos_contains2XXStatusCode;

@end

NS_ASSUME_NONNULL_END
