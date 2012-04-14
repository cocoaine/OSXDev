//
//  ForumInfo.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 14..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "ForumInfo.h"

@implementation ForumInfo

@synthesize title = _title;
@synthesize desc = _desc;
@synthesize href = _href;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"";
		self.desc = @"";
		self.href = @"";
    }
    return self;
}

- (void)dealloc
{
    [_title release];
	[_desc release];
	[_href release];
	
    [super dealloc];
}

+ (ForumInfo *)forumInfoWithTitle:(NSString *)title desc:(NSString *)desc href:(NSString *)href {
	ForumInfo *forumInfo = [[[ForumInfo alloc] init] autorelease];
	
	forumInfo.title = title;
	forumInfo.desc = desc;
	forumInfo.href = href;
	
	return forumInfo;
}

@end
