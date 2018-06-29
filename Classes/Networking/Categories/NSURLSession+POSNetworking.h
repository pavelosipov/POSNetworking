//
//  NSURLSession+POSNetworking.h
//  POSNetworking
//
//  Created by p.osipov on 29/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <ReactiveObjC/RACSubject.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (POSNetworking)

@property (nonatomic, readonly) RACSubject *pos_invalidateSubject;

@end

NS_ASSUME_NONNULL_END
