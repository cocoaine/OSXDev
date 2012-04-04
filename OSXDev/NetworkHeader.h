//
//  NetworkHeader.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#ifndef OSXDev_NetworkHeader_h
#define OSXDev_NetworkHeader_h

#define	kOSXDevURLMain				@"index.php"
#define kOSXDevURLViewForum			@"viewforum.php"
#define kOSXDevURLViewTopic			@"viewtopic.php"
#define kOSXDevURLMemberList		@"memberlist.php"
#define kOSXDevURLLogin				@"ucp.php"
#define kOSXDevURLPosting			@"posting.php"

#define kOSXDevXPathMain			@"//div[@id='page-body']/div[@class='forabg']/ul[contains(@class, 'forums')]/li[contains(@class, 'row')]/dl/dt"
#define kOSXDevXPathForumHeaders	@"//li[contains(@class, 'header')]/dl/dt"
#define kOSXDevXPathPagination		@"//div[contains(@class, 'pagination')]"
#define kOSXDevXPathTopicList		@"//dl[contains(@style, 'topic')]"
#define kOSXDevXPathPostBody		@"//div[contains(@class,'postbody')]"
#define kOSXDevXPathPostingSubject	@"//input[contains(@name, 'subject')]"
#define kOSXDevXPathTopicCurPostId	@"//input[contains(@name, 'topic_cur_post_id')]"
#define kOSXDevXPathLastClick		@"//input[contains(@name, 'lastclick')]"
#define kOSXDevXPathCreationTime	@"//input[contains(@name, 'creation_time')]"
#define kOSXDevXPathFormToken		@"//input[contains(@name, 'form_token')]"

#define kOSXDevURLRequestTimeout	30.f

typedef enum _NetworkURLType {
	NetworkURLForumList		= 0,
	NetworkURLForum			= 1,
	NetworkURLTopic			= 2,
	NetworkURLMember		= 3,
	NetworkURLLogin			= 4,
	NetworkURLPostingData	= 5,
	NetworkURLPosting		= 6,
} NetworkURLType;

typedef enum _NetworkRequestType {
	NetworkRequestForumList		= 0,
	NetworkRequestViewForum		= 1,
	NetworkRequestViewTopic		= 2,
	NetworkRequestViewMember	= 3,
	NetworkRequestLogin			= 4,
	NetworkRequestPostingData	= 5,
	NetworkRequestPosting		= 6,
} NetworkRequestType;

@protocol NetworkObjectDelegate <NSObject>

@required
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType;
- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error;

@end

#endif
