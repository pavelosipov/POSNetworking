//
//  NSURLSessionTask+POSNetworking.h
//  POSNetworking
//
//  Created by p.osipov on 29/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSProgressValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (POSNetworking)

@property (nonatomic, setter = pos_setAllowUntrustedSSLCertificates:) NSNumber *pos_allowUntrustedSSLCertificates;

@property (nonatomic, copy, setter = pos_setUploadProgress:)
void (^pos_uploadProgress)(POSProgressValue progress);

@property (nonatomic, copy, setter = pos_setCompletionHandler:)
void (^pos_completionHandler)(NSError *error);

@property (nonatomic, copy, setter = pos_setBodyStreamBuilder:)
NSInputStream *(^pos_bodyStreamBuilder)(void);

@property (nonatomic, copy, setter = pos_setResponseHandler:)
NSURLSessionResponseDisposition (^pos_responseHandler)(NSURLResponse *response);

@property (nonatomic, copy, setter = pos_setDataHandler:)
void (^pos_dataHandler)(NSData *data);

@property (nonatomic, copy, setter = pos_setDownloadProgress:)
void (^pos_downloadProgress)(POSProgressValue progress);

@property (nonatomic, copy, setter = pos_setDownloadCompletionHandler:)
void (^pos_downloadCompletionHandler)(NSURL *fileLocation);

- (void)pos_start;

@end

NS_ASSUME_NONNULL_END
