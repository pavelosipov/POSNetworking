//
//  POSHTTPRequestBuilder.h
//  POSNetworking
//
//  Created by p.osipov on 03/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

///
/// @brief   Block for user-defined handling responses from NSURLSessionTask.
///
/// @param   underlyingHandler Base implementation of POSHTTPResponseHandler
///
/// @remarks It is your job to validate both metadata and data.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns nil, then its signal completes without values.
/// @remarks Default handler will check, that status code has 2XX value and then use
///          responseDataHandler block to process data.
///
/// @return  Value which will be emitted by signal.
///
typedef id _Nullable (^POSHTTPCustomResponseHandler)(
    POSHTTPResponseHandler underlyingHandler,
    POSHTTPResponse *response,
    NSError **error);

///
/// Default metadata handler for incomming responses
///
typedef BOOL (^POSHTTPMetadataHandler)(NSHTTPURLResponse *metadata, NSError **error);

///
/// @brief   Block for handling metadata in the response from NSURLSessionTask.
///
/// @param   underlyingHandler Base implementation of POSHTTPMetadataHandler
///
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns NO, then it should return error in out parameter.
///
/// @return YES if response handling should proceed or NO to break handling and return error.
///
typedef BOOL (^POSHTTPCustomMetadataHandler)(
    POSHTTPMetadataHandler underlyingHandler,
    NSHTTPURLResponse *metadata,
    NSError **error);

///
/// @brief   Block for handling data in the response from NSURLSessionTask.
///
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns nil, then its signal completes without values.
/// @remarks Default handler returns responseData.
///
/// @return Value which will be emitted by signal.
///
typedef id _Nullable (^POSHTTPDataHandler)(NSData *responseData, NSError **error);

/// Factory block for building request-specific NSURLSessionTask.
typedef NSURLSessionTask * _Nullable (^POSURLSessionTaskFactory)(
    NSURLRequest *request,
    id<POSHTTPGateway> gateway,
    NSError **error);

#pragma mark -

///
/// @brief      Builds request with specified attributes.
///
/// @discussion It creates GET request by default, but POSHTTPGET builder is more appropriate
///             for that purpose because of more declarative name.
///
@interface POSHTTPRequestBuilder : NSObject

@property (nonatomic, readonly, copy) POSURLSessionTaskFactory URLSessionTaskFactory;

- (id<POSHTTPRequest>)build;

/// Path part of the URL, which will be appended to host's base URL and host's URLPathPrefix if such option exists.
- (instancetype)withOptions:(nullable POSHTTPRequestOptions *)options;

/// Request's body.
- (instancetype)withBody:(nullable NSData *)body;

/// Block for handling metadata in the response from NSURLSessionTask.
/// @see POSHTTPMetadataHandler description for details.
- (instancetype)withMetadataHandler:(nullable POSHTTPCustomMetadataHandler)handler;

/// Block for handling data in the response from NSURLSessionTask.
/// @see POSHTTPDataHandler description for details.
- (instancetype)withDataHandler:(nullable POSHTTPDataHandler)handler;

/// Block for handling both data and metadata in the response from NSURLSessionTask.
/// @see POSHTTPResponseHandler description for details.
- (instancetype)withResponseHandler:(nullable POSHTTPCustomResponseHandler)handler;

@end

NS_ASSUME_NONNULL_END
