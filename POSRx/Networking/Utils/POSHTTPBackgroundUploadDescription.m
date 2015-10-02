//
//  POSHTTPBackgroundUploadDescription.m
//  POSRx
//
//  Created by Pavel Osipov on 11.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPBackgroundUploadDescription.h"
#import "POSHTTPRequestExecutionOptions.h"
#import "POSHTTPBackgroundUploadRequest.h"

@implementation POSHTTPBackgroundUploadDescription

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _request = [aDecoder decodeObjectForKey:@"request"];
        _hostURL = [aDecoder decodeObjectForKey:@"hostURL"];
        _options = [aDecoder decodeObjectForKey:@"options"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_request forKey:@"request"];
    [aCoder encodeObject:_hostURL forKey:@"hostURL"];
    if (_options) {
        [aCoder encodeObject:_options forKey:@"options"];
    }
}

+ (instancetype)fromString:(NSString *)description {
    if (!description) {
        return nil;
    }
    @try {
        NSData *data = [description dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) {
            return nil;
        }
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        return [unarchiver decodeObject];
    } @catch (NSException *exception) {
        return nil;
    }
}

- (NSString *)asString {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc ] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeRootObject:self];
    [archiver finishEncoding];
    return [[NSString alloc]
            initWithData:data
            encoding:NSUTF8StringEncoding];
}

@end
