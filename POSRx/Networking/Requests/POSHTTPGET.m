//
//  POSHTTPGET.m
//  POSRx
//
//  Created by Pavel Osipov on 23.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPGET.h"

@implementation POSHTTPGET

+ (POSHTTPRequest *)method:(NSString *)method {
    return [[POSHTTPRequest alloc]
            initWithType:POSHTTPRequestTypeGET
            endpointMethod:method
            body:nil
            headerFields:nil];
}

@end
