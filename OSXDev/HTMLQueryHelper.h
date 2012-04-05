//
//  HTMLQueryHelper.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkHeader.h"

@interface HTMLHelper : NSObject

+ (NSDictionary *)convertForumInfo:(NSData *)htmlData;
+ (NSDictionary *)convertTopicInfo:(NSData *)htmlData;
+ (NSDictionary *)convertThreadInfo:(NSData *)htmlData;
+ (NSDictionary *)convertPostingInfo:(NSData *)htmlData;
+ (NSString *)getSid:(NSData *)htmlData;
+ (BOOL)isValidData:(NSData *)htmlData requestType:(NetworkRequestType)requestType;

@end

@interface QueryHelper : NSObject

+ (NSString *)valueWithURLString:(NSString *)urlString token:(NSString *)token;

@end
