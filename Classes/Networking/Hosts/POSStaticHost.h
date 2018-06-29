//
//  MRCStaticHost.h
//  MRCloudSDK
//
//  Created by Pavel Osipov on 11/04/16.
//  Copyright © 2016 Mail.Ru Group. All rights reserved.
//

#import "MRCHost.h"

NS_ASSUME_NONNULL_BEGIN

/// Host which URL will not change during its lifetime.
@interface MRCStaticHost : MRCHost

/// Th designated initializer.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<MRCTracker>)tracker
                       URL:(NSURL *)URL;

/// Hidden initializer of the super class.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<MRCTracker>)tracker NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
