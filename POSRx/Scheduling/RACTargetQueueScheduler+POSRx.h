//
//  RACTargetQueueScheduler+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#   import <ReactiveObjC/ReactiveObjC.h>
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@interface RACTargetQueueScheduler (POSRx)

+ (RACTargetQueueScheduler *)pos_scheduler;
+ (RACTargetQueueScheduler *)pos_mainThreadScheduler;

@end

NS_ASSUME_NONNULL_END
