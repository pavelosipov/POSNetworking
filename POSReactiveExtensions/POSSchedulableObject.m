//
//  POSSchedulableObject.m
//  POSReactiveExtensions
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@interface POSScheduleProtectionOptions ()
@property (nonatomic) RACSequence *includedSelectors;
@property (nonatomic) RACSequence *excludedSelectors;
@end

@implementation POSScheduleProtectionOptions

+ (instancetype)defaultOptionsForClass:(Class)aClass {
    return [self.class include:[POSSchedulableObject selectorsForClass:aClass]
                       exclude:[POSSchedulableObject selectorsForClass:[NSObject class]]];
}

+ (instancetype)include:(RACSequence *)includes exclude:(RACSequence *)excludes {
    POSScheduleProtectionOptions *options = [[POSScheduleProtectionOptions alloc] init];
    options.includedSelectors = includes;
    options.excludedSelectors = excludes;
    return options;
}

- (instancetype)include:(RACSequence *)includes {
    _includedSelectors = _includedSelectors ? [_includedSelectors concat:includes] : includes;
    return self;
}

- (instancetype)exclude:(RACSequence *)excludes {
    _excludedSelectors = _excludedSelectors ? [_excludedSelectors concat:excludes] : excludes;
    return self;
}

@end

@interface POSSchedulableObject ()
@property (nonatomic) RACScheduler *scheduler;
@end

@implementation POSSchedulableObject

- (instancetype)init {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
            reason:[NSString stringWithFormat:@"Unexpected deadly init invokation '%@', use %@ instead.",
                    NSStringFromSelector(_cmd),
                    NSStringFromSelector(@selector(initWithScheduler:))]
            userInfo:nil];
}

- (instancetype)initWithScheduler:(RACScheduler *)scheduler {
    NSParameterAssert(scheduler);
    if (self = [super init]) {
        NSParameterAssert([self.class
                           protect:self
                           forScheduler:scheduler
                           options:[[POSScheduleProtectionOptions
                                     defaultOptionsForClass:[self class]]
                                    exclude:[self.class selectorsForProtocol:@protocol(POSSchedulable)]]]);
        _scheduler = scheduler;
    }
    return self;
}

- (instancetype)initWithScheduler:(RACScheduler *)scheduler options:(POSScheduleProtectionOptions *)options {
    NSParameterAssert(scheduler);
    if (self = [super init]) {
        NSParameterAssert([self.class protect:self forScheduler:scheduler options:options]);
        _scheduler = scheduler;
    }
    return self;
}

#pragma mark - POSSchedulable

- (RACScheduler *)scheduler {
    return _scheduler;
}

#pragma mark - POSSchedulableObject

+ (BOOL)protect:(id)object forScheduler:(RACScheduler *)scheduler {
    return [self.class protect:object
                  forScheduler:scheduler
                       options:[POSScheduleProtectionOptions defaultOptionsForClass:[object class]]];
}

+ (BOOL)protect:(id)object forScheduler:(RACScheduler *)scheduler options:(POSScheduleProtectionOptions *)options {
    if (!options.includedSelectors) {
        return YES;
    }
    NSMutableArray *protectingSelectors = [[options.includedSelectors array] mutableCopy];
    if (options.excludedSelectors) {
        [protectingSelectors removeObjectsInArray:[options.excludedSelectors array]];
    }
    for (NSValue *selectorValue in protectingSelectors) {
        SEL selector = (SEL)[selectorValue pointerValue];
        NSString *selectorName = NSStringFromSelector(selector);
        if ([selectorName containsString:@"init"] ||
            [selectorName containsString:@".cxx_destruct"] ||
            [selectorName containsString:@"aspects__"]) {
            continue;
        }
        NSError *error;
        id hooked = [object aspect_hookSelector:selector withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
            if ([aspectInfo instance] == object && [RACScheduler currentScheduler] != scheduler) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Incorrect scheduler to invoke '%@'.", selectorName]
                                             userInfo:nil];
            }
        } error:&error];
        if (!hooked) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
    }
    return YES;
}

+ (RACSequence *)selectorsForClass:(Class)aClass {
    return [[self.class p_selectorSetForClass:aClass] rac_sequence];
}

+ (RACSequence *)selectorsForProtocol:(Protocol *)aProtocol {
    return [[self.class p_selectorSetForProtocol:aProtocol] rac_sequence];
}

#pragma mark - Private

+ (NSSet *)p_selectorSetForClass:(Class)aClass {
    Class base = class_getSuperclass(aClass);
    NSSet *baseSelectors = base ? [self.class p_selectorSetForClass:base] : [NSSet set];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    NSMutableSet *selectors = [NSMutableSet setWithCapacity:methodCount];
    for (unsigned int i = 0; i < methodCount; ++i) {
        [selectors addObject:[NSValue valueWithPointer:method_getName(methods[i])]];
    }
    free(methods);
    [selectors unionSet:baseSelectors];
    return selectors;
}

+ (NSSet *)p_selectorSetForProtocol:(Protocol *)aProtocol {
    unsigned int methodCount = 0;
    NSMutableSet *selectors = [NSMutableSet setWithCapacity:methodCount];
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(aProtocol, YES, YES, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        [selectors addObject:[NSValue valueWithPointer:methods[i].name]];
    }
    free(methods);
    return selectors;
}

@end
