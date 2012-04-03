//
//  HTMLQueryHelper.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLHelper : NSObject

+ (NSDictionary *)convertForumInfo:(NSData *)htmlData;
+ (NSDictionary *)convertTopicInfo:(NSData *)htmlData;
+ (NSDictionary *)convertThreadInfo:(NSData *)htmlData;
+ (NSString *)getSid:(NSData *)htmlData;

@end

@interface QueryHelper : NSObject

+ (NSInteger)identifierWithURLString:(NSString *)urlString token:(NSString *)token;
+ (NSString *)valueWithURLString:(NSString *)urlString token:(NSString *)token;

@end
