//
//  RACSignal+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 13.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (POSRx)

- (id)posrx_await;

@end
