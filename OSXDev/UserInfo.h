//
//  UserInfo.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 BRID. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _UserInfoValue {
	UserInfoDefault		= 0,
	UserInfoNO			= 1,
	UserInfoYES			= 2,
} UserInfoValue;

@interface UserInfo : NSObject

@property (assign, nonatomic) BOOL autoLogin;
@property (assign, nonatomic) BOOL viewOnline;

+ (UserInfo *)sharedInfo;

- (NSString *)userId;
- (NSString *)userPassword;
- (void)setUserId:(NSString *)userId;
- (void)setUserPassword:(NSString *)userPassword;

@end
