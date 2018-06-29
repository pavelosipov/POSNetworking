//
//  POSHTTPRequest+MRCSDK.h
//  MRCloudSDK
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Mail.Ru Group. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

typedef __nullable id (^MRCHTTPRequestResponseHandler)(POSHTTPResponse *response, NSError **error);
typedef BOOL (^MRCHTTPRequestResponseMetadataHandler)(NSHTTPURLResponse *metadata, NSError **error);
typedef __nullable id (^MRCHTTPRequestResponseDataHandler)(NSData *responseData, NSError **error);

@interface POSHTTPRequest (MRCSDK)

/// @brief Block for handling response from HTTPGateway.
/// @remarks It is your job to validate both metadata and data.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns nil, then its signal completes without values.
/// @remarks Default handler will check, that status code has 2XX value and then use
///          responseDataHandler block to process data.
/// @return Value which will be emitted by signal.
@property (nonatomic, copy, nullable, setter = mrc_setResponseHandler:) MRCHTTPRequestResponseHandler mrc_responseHandler;

/// @brief Block for handling metadata in the response from HTTPGateway.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns NO, then it should return error in out parameter.
/// @return YES if response handling should proceed or NO to break handling and return error.
@property (nonatomic, copy, nullable, setter = mrc_setResponseMetadataHandler:) MRCHTTPRequestResponseMetadataHandler mrc_responseMetadataHandler;

/// @brief Block for handling data in the response from HTTPGateway.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns nil, then its signal completes without values.
/// @remarks Default handler returns responseData.
/// @return Value which will be emitted by signal.
@property (nonatomic, copy, nullable, setter = mrc_setResponseDataHandler:) MRCHTTPRequestResponseDataHandler mrc_responseDataHandler;

@end

#pragma mark -

/// Helpers around NSHTTPURLResponse.
@interface NSHTTPURLResponse (MRCSDK)

/// @return YES if status code is in range [200..299].
- (BOOL)mrc_contains2XXStatusCode;

@end

#pragma mark -

@interface NSNumber (MRCSDK)

/// @return YES if status code is in range [200..299].
- (BOOL)mrc_contains2XXStatusCode;

@end


NS_ASSUME_NONNULL_END
