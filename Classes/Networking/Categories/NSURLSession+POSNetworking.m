//
//  NSURLSession+POSNetworking.m
//  POSNetworking
//
//  Created by p.osipov on 29/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSURLSession+POSNetworking.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

static char kURLSessionInvalidateSubject;

@implementation NSURLSession (POSNetworking)

- (RACSubject *)pos_invalidateSubject {
    RACSubject *subject = objc_getAssociatedObject(self, &kURLSessionInvalidateSubject);
    if (!subject) {
        subject = [RACSubject subject];
        objc_setAssociatedObject(self, &kURLSessionInvalidateSubject, subject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return subject;
}

@end


NS_ASSUME_NONNULL_END
