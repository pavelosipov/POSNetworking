//
//  POSHTTPGET.h
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestBuilder.h"

NS_ASSUME_NONNULL_BEGIN

typedef POSHTTPRequestBuilder POSHTTPGET;

#pragma mark -

@interface POSHTTPGETFile : POSHTTPGET

/// Notifies how many bytes were received from remote host.
- (instancetype)withDownloadProgress:(void (^ _Nullable)(POSHTTPRequestProgress progress))downloadProgress;

/// Handler of the downloaded file at specified path.
- (instancetype)withFileHandler:(void (^ _Nullable)(NSURL *fileLocation))fileHandler;

@end

NS_ASSUME_NONNULL_END
