//
//  POSSchedulable.h
//  POSReactiveExtensions
//
//  Created by Pavel Osipov on 12.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol POSSchedulable <NSObject>

@property (nonatomic, readonly) RACScheduler *scheduler;

@end
