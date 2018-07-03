//
//  POSHTTPRequestProgress.h
//  POSNetworking
//
//  Created by Pavel Osipov on 29/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Value which indicates absence of the value in POSHTTPRequestProgress structure.
FOUNDATION_EXTERN uint64_t const POSProgressValueUnknownUnitsCount;

/// Represents progress of some operation.
typedef struct {
    uint64_t ready;
    uint64_t total;
} POSHTTPRequestProgress;

NS_ASSUME_NONNULL_END
