//
//  UserInfo.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _UserInfoValue {
	UserInfoDefault		= 0,
	UserInfoNO			= 1,
	UserInfoYES			= 2,
} UserInfoValue;

typedef enum _UserInfoLoginStatus {
	UserInfoLoginStatusNotLoggedIn	= 0,
	UserInfoLoginStatusLoggedIn		= 1,
} UserInfoLoginStatus;

@interface UserInfo : NSObject

@property (assign, nonatomic) BOOL autoLogin;
@property (assign, nonatomic) BOOL viewOnline;
@property (assign, nonatomic) UserInfoLoginStatus loginStatus;
@property (retain, nonatomic) NSString *sid;

+ (UserInfo *)sharedInfo;

- (void)logout;
- (NSString *)userId;
- (NSString *)userPassword;
- (void)setUserId:(NSString *)userId;
- (void)setUserPassword:(NSString *)userPassword;

@end
