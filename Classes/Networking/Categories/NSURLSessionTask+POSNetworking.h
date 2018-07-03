//
//  NSURLSessionTask+POSNetworking.h
//  POSNetworking
//
//  Created by p.osipov on 29/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestProgress.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (POSNetworking)

@property (nonatomic, nullable, setter = pos_setAllowUntrustedSSLCertificates:) NSNumber *pos_allowUntrustedSSLCertificates;

@property (nonatomic, nullable, copy, setter = pos_setUploadProgress:)
void (^pos_uploadProgress)(POSHTTPRequestProgress progress);

@property (nonatomic, nullable, copy, setter = pos_setCompletionHandler:)
void (^pos_completionHandler)(NSError *error);

@property (nonatomic, nullable, copy, setter = pos_setBodyStreamBuilder:)
NSInputStream * _Nullable (^pos_bodyStreamBuilder)(void);

@property (nonatomic, nullable, copy, setter = pos_setDataHandler:)
void (^pos_dataHandler)(NSData *data);

@property (nonatomic, nullable, copy, setter = pos_setDownloadProgress:)
void (^pos_downloadProgress)(POSHTTPRequestProgress progress);

@property (nonatomic, nullable, copy, setter = pos_setDownloadCompletionHandler:)
void (^pos_downloadCompletionHandler)(NSURL *fileLocation);

- (void)pos_start;

@end

NS_ASSUME_NONNULL_END
