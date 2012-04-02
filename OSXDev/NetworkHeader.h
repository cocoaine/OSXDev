//
//  NetworkHeader.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#ifndef OSXDev_NetworkHeader_h
#define OSXDev_NetworkHeader_h

#define kOSXDevURLPrefix			@"http://www.osxdev.org/phpBB3/"
#define	kOSXDevURLMain				@"index.php"
#define kOSXDevURLViewForum			@"viewforum.php"
#define kOSXDevURLViewTopic			@"viewtopic.php"
#define kOSXDevURLMemberList		@"memberlist.php"
#define kOSXDevURLLogin				@"ucp.php"

#define kOSXDevXPathMain			@"//div[@id='page-body']/div[@class='forabg']/ul[@class='topiclist forums']/li[@class='row']/dl[@class='icon']/dt"
#define kOSXDevXPathForumHeaders	@"//li[contains(@class, 'header')]"
#define kOSXDevXPathPagination		@"//div[contains(@class, 'pagination')]"
#define kOSXDevXPathTopicList		@"//dl[contains(@style, 'topic_read')]"
#define kOSXDevXPathPostBody		@"//div[contains(@class,'postbody')]"

#define kOSXDevURLRequestTimeout	30.f

typedef enum _NetworkURLType {
	NetworkURLMain			= 0,
	NetworkURLForum			= 1,
	NetworkURLTopic			= 2,
	NetworkURLMember		= 3,
	NetworkURLLogin			= 4,
} NetworkURLType;

typedef enum _NetworkRequestType {
	NetworkRequestMain			= 0,
	NetworkRequestViewForum		= 1,
	NetworkRequestViewTopic		= 2,
	NetworkRequestViewMember	= 3,
	NetworkRequestLogin			= 4,
} NetworkRequestType;

@protocol NetworkObjectDelegate <NSObject>

@required
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType;
- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error;

@end

#endif
