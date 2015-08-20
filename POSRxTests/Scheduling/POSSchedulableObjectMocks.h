//
//  POSSchedulableObjectMocks.h
//  POSRx
//
//  Created by Osipov on 25.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

@protocol Empty <NSObject>
@end

@interface EmptyMock : NSObject
@end

@protocol TestingA <NSObject>
- (void)a;
@end

@interface TestA : NSObject <TestingA>
@end

@protocol SafeProtocol <NSObject>
- (void)methodA;
@end

@interface SchedulableObject : POSSchedulableObject <SafeProtocol>
@end