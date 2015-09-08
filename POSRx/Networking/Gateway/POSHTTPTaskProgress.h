//
//  POSHTTPTaskProgress.h
//  POSRx
//
//  Created by Pavel Osipov on 18.07.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN uint64_t const POSTaskProgressUnknownUnitsCount;

@interface POSHTTPTaskProgress : NSObject

@property (nonatomic, readonly) uint64_t readyUnits;
@property (nonatomic, readonly) uint64_t totalUnits;

- (instancetype)initWithReadyUnits:(uint64_t)readyUnits
                        totalUnits:(uint64_t)totalUnits;

@end
