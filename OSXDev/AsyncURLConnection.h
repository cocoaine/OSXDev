//
//  AsyncURLConnection.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NetworkHeader.h"

@interface AsyncURLConnection : NSURLConnection

@property (retain, nonatomic) NSString *identifier;
@property (retain, nonatomic) NSMutableData *data;
@property (assign, nonatomic) NetworkRequestType requestType;
@property (retain, nonatomic) NSURL *URL;
@property (retain, nonatomic) NSHTTPURLResponse * response;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(NetworkRequestType)requestType;

- (void)resetDataLength;
- (void)appendData:(NSData *)data;

- (NSString *)identifier;
- (NSData *)data;
- (NSURL *)URL;
- (NetworkRequestType)requestType;
- (NSString *)description;

@end
