//
//  GlobalHeader.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 30..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#ifndef OSXDev_GlobalHeader_h
#define OSXDev_GlobalHeader_h

#import "NetworkObject.h"
#import "AsyncURLConnection.h"
#import "HTMLQueryHelper.h"
#import "SVProgressHUD.h"
#import "UserInfo.h"

#define kOSXDevThreadMaxCount				10
#define kOSXDevTopicMaxCount				25

#define kOSXDevBarButtonSystemItemPrev		101
#define kOSXDevBarButtonSystemItemNext		102

#define kOSXDevAlertTagMovePage				1441
#define kOSXDevAlertTagError				1442
#define kOSXDevAlertTagErrorLoading			1443
#define kOSXDevAlertTagLoginRequired		1444

#define kOSXDevErrorLabelTag				5901

#define kOSXDevURLPrefix					@"http://www.osxdev.org/phpBB3/"

#define kOSXDevNotificationLoginSucceed		@"kOSXDevNotificationLoginSucceed"

#define UIViewAutoresizingFlexibleAll		(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth)

#endif
