//
//  TopicInfo.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 14..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "TopicInfo.h"

@implementation TopicInfo

@synthesize title = _title;
@synthesize desc = _desc;
@synthesize href = _href;
@synthesize threadCount = _threadCount;
@synthesize recentDesc = _recentDesc;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"";
		self.desc = @"";
		self.href = @"";
		self.threadCount = @"";
		self.recentDesc = @"";
    }
    return self;
}

- (void)dealloc
{
	[_title release];
	[_desc release];
	[_href release];
	[_threadCount release];
	[_recentDesc release];
    
    [super dealloc];
}

+ (TopicInfo *)topicInfoWithTitle:(NSString *)title desc:(NSString *)desc href:(NSString *)href threadCount:(NSString *)threadCount recentDesc:(NSString *)recentDesc {
	TopicInfo *topicInfo = [[[TopicInfo alloc] init] autorelease];
	
	topicInfo.title = title;
	topicInfo.desc = desc;
	topicInfo.href = href;
	topicInfo.threadCount = threadCount;
	topicInfo.recentDesc = recentDesc;
	
	return topicInfo;
}

@end
