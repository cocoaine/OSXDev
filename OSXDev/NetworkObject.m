//
//  NetworkObject.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "NetworkObject.h"

#define kMobileSafariUserAgent		@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"
#define kOSXDevMultipartBoundary	@"0xKhTmLbOuNdArY"

#define kOSXDevHTTPMethodGet		@"GET"
#define kOSXDevHTTPMethodPost		@"POST"
#define kOSXDevHTTPMethodMultipart	@"MULTIPART"

@interface NetworkObject (PrivateMethods)
- (BOOL)isValidDelegateForSelector:(SEL)selector;
- (NSURL *)getURLWithType:(NetworkURLType)urlType parameters:(NSDictionary *)params;
- (NSString *)encodeURL:(NSString *)string;
- (NSData *)setPostBody:(NSDictionary *)postParams;
- (NSData *)setMultipartBody:(NSDictionary *)postParams;
- (NSString *)sendRequestWithMethod:(NSString *)method url:(NSURL *)url queryParameters:(NSDictionary *)queryParams
						requestType:(NetworkRequestType)requestType isMobile:(BOOL)isMobile;
- (void)loginSucceedNotificationCalled:(NSNotification *)notification;
//- (void)cookieChangedNotificationCalled:(NSNotification *)notification;
@end

@interface NetworkObject (NSURLConnectionDelegate)
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(AsyncURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(AsyncURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(AsyncURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(AsyncURLConnection *)connection;
@end

@implementation NetworkObject

@synthesize delegate = _delegate;
@synthesize connections = _connections;

// MARK: -
// MARK: << Default methods >>
- (id)initWithDelegate:(id <NetworkObjectDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(loginSucceedNotificationCalled:) 
													 name:kOSXDevNotificationLoginSucceed
												   object:nil];
		
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(cookieChangedNotificationCalled:)
//													 name:NSHTTPCookieManagerCookiesChangedNotification
//												   object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kOSXDevNotificationLoginSucceed
												  object:nil];
	
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//													name:NSHTTPCookieManagerCookiesChangedNotification
//												  object:nil];
	
    self.delegate = nil;
	
	if ([self numberOfConnections] > 0) {
		[self closeAllConnections];
	}
	
	[_connections release];
	
    [super dealloc];
}

// MARK: -
// MARK: << Public methods >>
- (NSUInteger)numberOfConnections {
	return [_connections count];
}

- (NSArray *)connectionIdentifiers {
	return [_connections allKeys];
}
- (void)closeConnection:(NSString *)connectionIdentifier {
	AsyncURLConnection *connection = [_connections objectForKey:connectionIdentifier];
    if (connection) {
        [connection cancel];
        [_connections removeObjectForKey:connectionIdentifier];
    }
}

- (void)closeAllConnections {
	[[_connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_connections removeAllObjects];
}

- (NSString *)forumList {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setObject:[NSString stringWithFormat:@"%@", @"1"] forKey:@"f"];
	
	NSURL *url = [self getURLWithType:NetworkURLForum parameters:params];
	
	return [self sendRequestWithMethod:kOSXDevHTTPMethodGet url:url queryParameters:nil
						   requestType:NetworkRequestForumList isMobile:NO];
}

- (NSString *)topicListWithForumId:(NSInteger)forumId start:(NSInteger)start {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:[NSString stringWithFormat:@"%d", forumId] forKey:@"f"];
	[params setObject:[NSString stringWithFormat:@"%d", start] forKey:@"start"];
	
	NSURL *url = [self getURLWithType:NetworkURLForum parameters:params];
	
	return [self sendRequestWithMethod:kOSXDevHTTPMethodGet url:url queryParameters:nil
						   requestType:NetworkRequestViewForum isMobile:NO];
}

- (NSString *)threadListWithForumId:(NSInteger)forumId topicId:(NSInteger)topicId start:(NSInteger)start {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[NSString stringWithFormat:@"%d", forumId] forKey:@"f"];
	[params setObject:[NSString stringWithFormat:@"%d", topicId] forKey:@"t"];
	[params setObject:[NSString stringWithFormat:@"%d", start] forKey:@"start"];
	
	NSURL *url = [self getURLWithType:NetworkURLTopic parameters:params];
	
	return [self sendRequestWithMethod:kOSXDevHTTPMethodGet url:url queryParameters:nil
						   requestType:NetworkRequestViewTopic isMobile:NO];
}

- (NSString *)login {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setObject:[NSString stringWithFormat:@"%@", @"login"] forKey:@"mode"];
	
	NSURL *url = [self getURLWithType:NetworkURLLogin parameters:params];
	
	NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithCapacity:0];
	[postParams setObject:[NSString stringWithFormat:@"%@", [[UserInfo sharedInfo] userId]] forKey:@"username"];
	[postParams setObject:[NSString stringWithFormat:@"%@", [[UserInfo sharedInfo] userPassword]] forKey:@"password"];
	
	// 자동 로그인은 클라이언트에서 관리한다.
	// 곧, 여기에서는 default off로 준다.
	[postParams setObject:[NSString stringWithFormat:@"%@", @"off"] forKey:@"autologin"];
	
	if ([UserInfo sharedInfo].viewOnline) {
		[postParams setObject:[NSString stringWithFormat:@"%@", @"on"] forKey:@"viewonline"];
	}
	else {
		[postParams setObject:[NSString stringWithFormat:@"%@", @"off"] forKey:@"viewonline"];
	}
	
	[postParams setObject:[NSString stringWithFormat:@"%@", @"index.php"] forKey:@"redirect"];
	[postParams setObject:[NSString stringWithFormat:@"로그인"] forKey:@"login"];
	
	return [self sendRequestWithMethod:kOSXDevHTTPMethodPost url:url queryParameters:postParams
						   requestType:NetworkRequestLogin isMobile:NO];
}

- (NSString *)postingDataWithForumId:(NSInteger)forumId topicId:(NSInteger)topicId {
	NSMutableDictionary *urlParams = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (topicId == -1) {
		// topic id가 -1이면 new post
		[urlParams setObject:[NSString stringWithFormat:@"%@", @"post"] forKey:@"mode"];
	}
	else {
		// reply
		[urlParams setObject:[NSString stringWithFormat:@"%@", @"reply"] forKey:@"mode"];
		[urlParams setObject:[NSString stringWithFormat:@"%d", topicId] forKey:@"t"];
	}
	
	[urlParams setObject:[NSString stringWithFormat:@"%d", forumId] forKey:@"f"];
	
	NSURL *url = [self getURLWithType:NetworkURLPostingData parameters:urlParams];
	
	return [self sendRequestWithMethod:kOSXDevHTTPMethodGet url:url queryParameters:nil
						   requestType:NetworkRequestPostingData isMobile:NO];
}

- (NSString *)postingWithSubject:(NSString *)subject message:(NSString *)message forumId:(NSInteger)forumId topicId:(NSInteger)topicId topicCurPostId:(NSString *)topicCurPostId lastClick:(NSString *)lastClick creationTime:(NSString *)creationTime formToken:(NSString *)formToken {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (topicId == -1) {
		// topic id가 -1이면 new post
		[params setObject:[NSString stringWithFormat:@"%@", @"post"] forKey:@"mode"];
	}
	else {
		// reply
		[params setObject:[NSString stringWithFormat:@"%@", @"reply"] forKey:@"mode"];
		[params setObject:[NSString stringWithFormat:@"%d", topicId] forKey:@"t"];
	}
	
	[params setObject:[NSString stringWithFormat:@"%d", forumId] forKey:@"f"];
	
	NSURL *url = [self getURLWithType:NetworkURLPosting parameters:params];
	
	NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithCapacity:0];
	[postParams setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"icon"];
	[postParams setObject:[NSString stringWithFormat:@"%@", subject] forKey:@"subject"];
	[postParams setObject:[NSString stringWithFormat:@"%d", 100] forKey:@"addbbcode20"];
	[postParams setObject:[NSString stringWithFormat:@"%@", message] forKey:@"message"];
	[postParams setObject:[NSString stringWithFormat:@"%@", @"마침"] forKey:@"post"];
	[postParams setObject:[NSString stringWithFormat:@"%@", @"off"] forKey:@"attach_sig"];
	[postParams setObject:[NSString stringWithFormat:@"%@", @""] forKey:@"fileupload"];
	[postParams setObject:[NSString stringWithFormat:@"%@", @""] forKey:@"filecomment"];
	
	if (topicCurPostId) {
		[postParams setObject:[NSString stringWithFormat:@"%@", topicCurPostId] forKey:@"topic_cur_post_id"];
	}
	
	[postParams setObject:[NSString stringWithFormat:@"%@", lastClick] forKey:@"lastclick"];
	[postParams setObject:[NSString stringWithFormat:@"%@", creationTime] forKey:@"creation_time"];
	[postParams setObject:[NSString stringWithFormat:@"%@", formToken] forKey:@"form_token"];
	
	return [self sendRequestWithMethod:kOSXDevHTTPMethodMultipart url:url queryParameters:postParams 
						   requestType:NetworkRequestPosting isMobile:NO];
}

@end

@implementation NetworkObject (PrivateMethods)

// MARK: -
// MARK: << Private methods >>
- (BOOL) isValidDelegateForSelector:(SEL)selector {
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}

- (NSURL *)getURLWithType:(NetworkURLType)urlType parameters:(NSDictionary *)params {
	NSMutableString *urlString = [NSMutableString stringWithString:kOSXDevURLPrefix];
	
	switch (urlType) {
		case NetworkURLForumList:
			[urlString appendString:kOSXDevURLMain];
			break;
			
		case NetworkURLForum:
			[urlString appendString:kOSXDevURLViewForum];
			break;
			
		case NetworkURLTopic:
			[urlString appendString:kOSXDevURLViewTopic];
			break;
			
		case NetworkURLLogin:
			[urlString appendString:kOSXDevURLLogin];
			break;
			
		case NetworkURLPosting:
		case NetworkURLPostingData:
			[urlString appendString:kOSXDevURLPosting];
			break;
			
		default:
			break;
	}
	
	if (params != nil) {
		// 쿼리스트링 달아주기
		[urlString appendString:@"?"];
		
		NSArray *allKeys = [params allKeys];
		
		for (NSInteger i = 0; i < [allKeys count]; i++) {
			NSString *key = [allKeys objectAtIndex:i];
			
			if (i == [allKeys count] - 1) {
				[urlString appendFormat:@"%@=%@", key, [params objectForKey:key]];
			}
			else {
				[urlString appendFormat:@"%@=%@&", key, [params objectForKey:key]];
			}
		}
	}
	
	if ([UserInfo sharedInfo].sid != nil) {
		[urlString appendFormat:@"&%@=%@", @"sid", [UserInfo sharedInfo].sid];
	}
	
//	NSLog(@"urlString : %@", urlString);
	
	return [NSURL URLWithString:urlString];
}

- (NSString *)encodeURL:(NSString *)string {
	NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))) autorelease];
	if (newString) {
		return newString;
	}
	
	return @"";
}

- (NSData *)setPostBody:(NSDictionary *)postParams {
	NSMutableString *postString = [NSMutableString string];
	
	NSArray *allKeys = [postParams allKeys];
	
	for (NSInteger i = 0; i < [allKeys count]; i++) {
		NSString *key = [allKeys objectAtIndex:i];
		NSString *value = [postParams objectForKey:key];
		
		if (i == [allKeys count] - 1) {
			NSString *paramString = [NSString stringWithFormat:@"%@=%@", [self encodeURL:key], [self encodeURL:value]];
			[postString appendFormat:@"%@", paramString];
		}
		else {
			NSString *paramString = [NSString stringWithFormat:@"%@=%@", [self encodeURL:key], [self encodeURL:value]];
			[postString appendFormat:@"%@&", paramString];
		}
	}
	
	NSLog(@"postString : %@", postString);
	
	NSData *requestData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	return requestData;
}

- (NSData *)setMultipartBody:(NSDictionary *)postParams {
	NSArray *keys = [postParams allKeys];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n", kOSXDevMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (NSInteger i = 0; i < [keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		NSString *value = [postParams objectForKey:key];
		
		if ([key isEqualToString:@"fileupload"]) {
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"fileupload", @""] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			
//			UIImage *image = (UIImage *)[postParams objectForKey:key];
//			NSData *imageData = UIImagePNGRepresentation(image);
//			[body appendData:[[NSString stringWithFormat:@"%@", imageData] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		else {
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
		if (i == [keys count] - 1) {
			[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kOSXDevMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		else {
			[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kOSXDevMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	return body;
}

- (NSString *)sendRequestWithMethod:(NSString *)method url:(NSURL *)url queryParameters:(NSDictionary *)queryParams
						requestType:(NetworkRequestType)requestType isMobile:(BOOL)isMobile {
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:kOSXDevURLRequestTimeout];
	NSLog(@"theRequest.HTTPShouldHandleCookies : %@", theRequest.HTTPShouldHandleCookies ? @"YES" : @"NO");
	[theRequest setHTTPShouldHandleCookies:YES];
	
	if ([method isEqualToString:kOSXDevHTTPMethodPost] || [method isEqualToString:kOSXDevHTTPMethodMultipart]) {
		[theRequest setHTTPMethod:@"POST"];
		
		if ([method isEqualToString:kOSXDevHTTPMethodMultipart]) {
			// multipart
			NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kOSXDevMultipartBoundary];
			[theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
			[theRequest setHTTPBody:[self setMultipartBody:queryParams]];
		}
		else {
			// post
			[theRequest setHTTPBody:[self setPostBody:queryParams]];
		}
	}
	
	if (isMobile) {
		[theRequest setValue:kMobileSafariUserAgent forHTTPHeaderField:@"User-Agent"];
	}
	
	// start network indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
    AsyncURLConnection *connection = [[AsyncURLConnection alloc] initWithRequest:theRequest 
																		delegate:self 
																	 requestType:requestType];
    
    if (!connection) {
        return nil;
    }
	else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    return [connection identifier];
}

- (void)loginSucceedNotificationCalled:(NSNotification *)notification {
	NSDictionary *loginInfo = notification.userInfo;
	
	NSString *sidString = [loginInfo objectForKey:@"sid"];
	if (sidString == nil) {
		[UserInfo sharedInfo].sid = nil;
	}
	else {
		[UserInfo sharedInfo].sid = sidString;
	}
}

/*
- (void)cookieChangedNotificationCalled:(NSNotification *)notification {
	NSLog(@"NSHTTPCookieManagerCookiesChangedNotification called");
	
	for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
		NSLog(@"changed cookie : %@", [cookie value]);
	}
}
 */

@end

@implementation NetworkObject (NSURLConnectionDelegate)

/*
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"didReceiveAuthenticationChallenge called");
	if ([[UserInfo sharedInfo] userId] && [[UserInfo sharedInfo] userPassword] &&
		[challenge previousFailureCount] == 0 && ![challenge proposedCredential]) {
		NSURLCredential *credential = [NSURLCredential credentialWithUser:[[UserInfo sharedInfo] userId] 
																 password:[[UserInfo sharedInfo] userPassword] 
															  persistence:NSURLCredentialPersistenceForSession];
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	}
	else {
		[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	}
}
 */

- (void)connection:(AsyncURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [connection resetDataLength];
    
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    [connection setResponse:resp];
	
//	NSLog(@"cookieAcceptPolicy == NSHTTPCookieAcceptPolicyAlways? %@", [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy == NSHTTPCookieAcceptPolicyAlways ? @"YES" : @"NO");
//    
//	NSHTTPURLResponse *respDebug = (NSHTTPURLResponse *)response;
//	NSLog(@"OSXDev debug : (%ld) [%@]:\r%@", 
//		  (long)[resp statusCode], 
//		  [NSHTTPURLResponse localizedStringForStatusCode:[respDebug statusCode]], 
//		  [respDebug allHeaderFields]);
}

- (void)connection:(AsyncURLConnection *)connection didReceiveData:(NSData *)data {
    [connection appendData:data];
}

- (void)connection:(AsyncURLConnection *)connection didFailWithError:(NSError *)error {
	// stop network indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSString *connectionIdentifier = [connection identifier];
	
	// Failed!!!
	if ([self isValidDelegateForSelector:@selector(requestFailed:requestType:error:)]) {
		[_delegate requestFailed:connectionIdentifier
					 requestType:[connection requestType]
						   error:error];
	}
    
    [_connections removeObjectForKey:connectionIdentifier];
}

- (void)connectionDidFinishLoading:(AsyncURLConnection *)connection {
	// stop network indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    NSInteger statusCode = [[connection response] statusCode];
	
    if (statusCode >= 400) {
		// 에러 처리.
        NSData *receivedData = [connection data];
        NSString *body = [receivedData length] ? [NSString stringWithUTF8String:[receivedData bytes]] : @"";
		
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[connection response], @"response", body, @"body", nil];
		
        NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:userInfo];
		if ([self isValidDelegateForSelector:@selector(requestFailed:requestType:error:)]) {
			[_delegate requestFailed:[connection identifier]
						 requestType:[connection requestType]
							   error:error];
		}
		
        [connection cancel];
		
		NSString *connectionIdentifier = [connection identifier];
		[_connections removeObjectForKey:connectionIdentifier];
		
        return;
    }
	
    NSString *connID = [connection identifier];
    NSData *receivedData = [connection data];
    if (receivedData) {
		if ([connection requestType] == NetworkRequestLogin) {
			// 로그인 처리
			NSString *sidString = [HTMLHelper getSid:receivedData];
			
			if (sidString != nil) {
				NSMutableDictionary *loginInfo = [NSMutableDictionary dictionaryWithCapacity:1];
				[loginInfo setObject:sidString forKey:@"sid"];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kOSXDevNotificationLoginSucceed object:nil userInfo:loginInfo];
			}
		}
		
		if ([self isValidDelegateForSelector:@selector(requestSucceed:forRequest:requestType:)]) {
			[_delegate requestSucceed:receivedData forRequest:connID requestType:[connection requestType]];
		}
    }
    
    [_connections removeObjectForKey:connID];
}

@end
