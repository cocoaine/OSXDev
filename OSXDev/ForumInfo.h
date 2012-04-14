//
//  ForumInfo.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 14..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumInfo : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *desc;
@property (retain, nonatomic) NSString *href;

+ (ForumInfo *)forumInfoWithTitle:(NSString *)title desc:(NSString *)desc href:(NSString *)href;

@end
