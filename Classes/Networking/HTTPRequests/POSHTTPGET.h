//
//  POSHTTPGET.h
//  POSNetworking
//
//  Created by Pavel Osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHTTPGET : POSHTTPRequestBuilder

+ (id<POSHTTPRequest>)request;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHTTPMethod:(NSString *)HTTPMethod NS_UNAVAILABLE;

@end

#pragma mark -

@interface POSHTTPGETFile : POSHTTPGET

/// Notifies how many bytes were received from remote host.
- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSHTTPRequestProgress progress))downloadProgress;

/// Handler of the downloaded file at specified path.
- (instancetype)withFileHandler:(void (^ _Nullable)(NSURL *fileLocation))fileHandler;

@end

NS_ASSUME_NONNULL_END
