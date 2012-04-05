//
//  UserInfo.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "UserInfo.h"

#import "SFHFKeychainUtils.h"

#define kOSXDevKeychainServiceName			@"OSXDev"
#define kOSXDevKeychainUserNameId			@"userId"
#define kOSXDevKeychainUserNamePassword		@"userPassword"
#define kOSXDevUserInfoKeyAutoLogin			@"kOSXDevUserInfoKeyAutoLogin"
#define kOSXDevUserInfoKeyViewOnline		@"kOSXDevUserInfoKeyViewOnline"

@implementation UserInfo

@synthesize autoLogin = _autoLogin;
@synthesize viewOnline = _viewOnline;
@synthesize loginStatus = _loginStatus;
@synthesize sid = _sid;

static UserInfo *sharedInfo = nil;

- (id)init
{
    self = [super init];
    if (self) {
		self.loginStatus = UserInfoLoginStatusNotLoggedIn;
		
		NSInteger tmpAutoLogin = [[NSUserDefaults standardUserDefaults] integerForKey:kOSXDevUserInfoKeyAutoLogin];
		switch (tmpAutoLogin) {
			case UserInfoDefault:
			case UserInfoYES:
			{
				self.autoLogin = YES;
			}
				break;
				
			case UserInfoNO:
			{
				self.autoLogin = NO;
			}
				break;
				
			default:
				break;
		}
		
		NSInteger tmpViewOnline = [[NSUserDefaults standardUserDefaults] integerForKey:kOSXDevUserInfoKeyViewOnline];
		switch (tmpViewOnline) {
			case UserInfoYES:
			{
				self.viewOnline = YES;
			}
				break;
				
			case UserInfoDefault:
			case UserInfoNO:
			{
				self.viewOnline = NO;
			}
				break;
				
			default:
				break;
		}
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
	static dispatch_once_t pred;
	
	dispatch_once(&pred, ^{
		if (sharedInfo == nil) {
			sharedInfo = [super allocWithZone:zone];
		}
	});
	
	return sharedInfo;
}

+ (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

- (oneway void)release {
	// do nothing...
}

- (id)autorelease {
	return self;
}

- (void)dealloc
{
	[_sid release];
	
    [super dealloc];
}

+ (UserInfo *)sharedInfo {
	static dispatch_once_t pred;
	
	dispatch_once(&pred, ^{
		if (sharedInfo == nil) {
			sharedInfo = [[UserInfo alloc] init];
		}
	});
	
	return sharedInfo;
}

// MARK: -
// MARK: << Public methods >>
- (void)logout {
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]) {
		[storage deleteCookie:cookie];
	}

	self.sid = nil;
	self.loginStatus = UserInfoLoginStatusNotLoggedIn;

	[[NSNotificationCenter defaultCenter] postNotificationName:kOSXDevNotificationLoginSucceed
														object:nil
													  userInfo:nil];
	
	[self setUserId:nil];
	[self setUserPassword:nil];
}

- (void)setAutoLogin:(BOOL)autoLogin {
	_autoLogin = autoLogin;
	
	if (autoLogin) {
		[[NSUserDefaults standardUserDefaults] setInteger:UserInfoYES forKey:kOSXDevUserInfoKeyAutoLogin];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setInteger:UserInfoNO forKey:kOSXDevUserInfoKeyAutoLogin];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setViewOnline:(BOOL)viewOnline {
	_viewOnline = viewOnline;
	
	if (viewOnline) {
		[[NSUserDefaults standardUserDefaults] setInteger:UserInfoYES forKey:kOSXDevUserInfoKeyViewOnline];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setInteger:UserInfoNO forKey:kOSXDevUserInfoKeyViewOnline];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userId {
	NSString *tmpUserId = [SFHFKeychainUtils getPasswordForUsername:kOSXDevKeychainUserNameId
													 andServiceName:kOSXDevKeychainServiceName
															  error:nil];
	
	if (tmpUserId) {
		return tmpUserId;
	}
	
	return nil;
}

- (NSString *)userPassword {
	NSString *tmpUserPassword = [SFHFKeychainUtils getPasswordForUsername:kOSXDevKeychainUserNamePassword
														   andServiceName:kOSXDevKeychainServiceName
																	error:nil];
	
	if (tmpUserPassword) {
		return tmpUserPassword;
	}
	
	return nil;
}

- (void)setUserId:(NSString *)userId {
	if (userId == nil) {
		[SFHFKeychainUtils deleteItemForUsername:kOSXDevKeychainUserNameId
								  andServiceName:kOSXDevKeychainServiceName
										   error:nil];
	}
	else {
		[SFHFKeychainUtils storeUsername:kOSXDevKeychainUserNameId
							 andPassword:userId
						  forServiceName:kOSXDevKeychainServiceName
						  updateExisting:YES
								   error:nil];
	}
}

- (void)setUserPassword:(NSString *)userPassword {
	if (userPassword == nil) {
		[SFHFKeychainUtils deleteItemForUsername:kOSXDevKeychainUserNamePassword
								  andServiceName:kOSXDevKeychainServiceName
										   error:nil];
	}
	else {
		[SFHFKeychainUtils storeUsername:kOSXDevKeychainUserNamePassword
							 andPassword:userPassword
						  forServiceName:kOSXDevKeychainServiceName
						  updateExisting:YES
								   error:nil];
	}
}

@end
