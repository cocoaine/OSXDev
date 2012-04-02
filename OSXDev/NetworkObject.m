//
//  NetworkObject.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "NetworkObject.h"

#define kMobileSafariUserAgent	@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

@interface NetworkObject (PrivateMethods)
- (BOOL)isValidDelegateForSelector:(SEL)selector;
- (NSURL *)getURLWithType:(NetworkURLType)urlType parameters:(NSDictionary *)params;
- (NSString *)encodeURL:(NSString *)string;
- (NSData *)setPostBody:(NSDictionary *)postParams;
- (NSString *)sendRequest:(NSMutableURLRequest *)theRequest 
			  requestType:(NetworkRequestType)requestType 
				 isMobile:(BOOL)isMobile;
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
@synthesize cookies = _cookies;
@synthesize sid = _sid;

// MARK: -
// MARK: << Default methods >>
- (id)initWithDelegate:(id <NetworkObjectDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
	
	[_connections release];
	[_cookies release];
	[_sid release];
	
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
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:kOSXDevURLRequestTimeout];
	// 모바일 페이지는 content desc가 없다...
	return [self sendRequest:request requestType:NetworkRequestMain isMobile:NO];
}

- (NSString *)topicListWithForumId:(NSInteger)forumId start:(NSInteger)start {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:[NSString stringWithFormat:@"%d", forumId] forKey:@"f"];
	[params setObject:[NSString stringWithFormat:@"%d", start] forKey:@"start"];
	
	NSURL *url = [self getURLWithType:NetworkURLForum parameters:params];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:kOSXDevURLRequestTimeout];
	
	return [self sendRequest:request requestType:NetworkRequestViewForum isMobile:NO];
}

- (NSString *)threadListWithForumId:(NSInteger)forumId topicId:(NSInteger)topicId start:(NSInteger)start {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[NSString stringWithFormat:@"%d", forumId] forKey:@"f"];
	[params setObject:[NSString stringWithFormat:@"%d", topicId] forKey:@"t"];
	[params setObject:[NSString stringWithFormat:@"%d", start] forKey:@"start"];
	
	NSURL *url = [self getURLWithType:NetworkURLTopic parameters:params];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:kOSXDevURLRequestTimeout];
	
	return [self sendRequest:request requestType:NetworkRequestViewTopic isMobile:NO];
}

- (NSString *)loginWithId:(NSString *)loginId password:(NSString *)password {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setObject:[NSString stringWithFormat:@"%@", @"login"] forKey:@"mode"];
	
	NSURL *url = [self getURLWithType:NetworkURLLogin parameters:params];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:kOSXDevURLRequestTimeout];
	
	NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithCapacity:0];
	[postParams setObject:[NSString stringWithFormat:@"%@", loginId] forKey:@"username"];
	[postParams setObject:[NSString stringWithFormat:@"%@", password] forKey:@"password"];
//	[postParams setObject:[NSString stringWithFormat:@"%@", @"on"] forKey:@"autologin"];
//	[postParams setObject:[NSString stringWithFormat:@"%@", @"off"] forKey:@"viewonline"];
	[postParams setObject:[NSString stringWithFormat:@"%@", @"index.php"] forKey:@"redirect"];
	[postParams setObject:[NSString stringWithFormat:@"%@", @"e28b8010c5990675ca47d7a71ebb7c7f"] forKey:@"sid"];
	[postParams setObject:[NSString stringWithFormat:@"로그인"] forKey:@"login"];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[self setPostBody:postParams]];
	
	return [self sendRequest:request requestType:NetworkRequestLogin isMobile:YES];
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
		case NetworkURLMain:
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
	
	NSLog(@"urlString : %@", urlString);
	
	if (self.sid != nil) {
		[urlString appendFormat:@"%@=%@", @"sid", self.sid];
	}
	
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
	
	NSData *requestData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	return requestData;
}

- (NSString *)sendRequest:(NSMutableURLRequest *)theRequest 
			  requestType:(NetworkRequestType)requestType 
				 isMobile:(BOOL)isMobile {
	if (isMobile) {
		[theRequest setValue:kMobileSafariUserAgent forHTTPHeaderField:@"User-Agent"];
	}
	
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

@end

@implementation NetworkObject (NSURLConnectionDelegate)

//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//	if (_username && _password && [challenge previousFailureCount] == 0 && ![challenge proposedCredential]) {
//		NSURLCredential *credential = [NSURLCredential credentialWithUser:_username password:_password 
//															  persistence:NSURLCredentialPersistenceForSession];
//		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//	}
//	else {
//		[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
//	}
//}

- (void)connection:(AsyncURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [connection resetDataLength];
    
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    [connection setResponse:resp];
	
	// 쿠키 관련 처리
	NSDictionary *theHeaders = [resp allHeaderFields];
	NSArray *theCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:theHeaders forURL:[response URL]];
	
	if ([theCookies count] > 0) {
		self.cookies = theCookies;
	}
    
	NSHTTPURLResponse *respDebug = (NSHTTPURLResponse *)response;
	NSLog(@"OSXDev debug : (%ld) [%@]:\r%@", 
		  (long)[resp statusCode], 
		  [NSHTTPURLResponse localizedStringForStatusCode:[respDebug statusCode]], 
		  [respDebug allHeaderFields]);
}

- (void)connection:(AsyncURLConnection *)connection didReceiveData:(NSData *)data {
    [connection appendData:data];
}

- (void)connection:(AsyncURLConnection *)connection didFailWithError:(NSError *)error {
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
		if ([self isValidDelegateForSelector:@selector(requestSucceed:forRequest:requestType:)]) {
			[_delegate requestSucceed:receivedData forRequest:connID requestType:[connection requestType]];
		}
    }
    
    [_connections removeObjectForKey:connID];
}

@end
