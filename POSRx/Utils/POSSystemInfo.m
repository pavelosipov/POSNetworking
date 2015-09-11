//
//  POSSystemInfo.m
//  POSRx
//
//  Created by Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSystemInfo.h"
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif

@implementation POSSystemInfo

+ (BOOL)isOutdatedOS {
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    return UIDevice.currentDevice.systemVersion.floatValue < 8.0;
#endif
    return NO;
}

@end
