//
//  HTMLQueryHelper.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "HTMLQueryHelper.h"

#import "TouchXML.h"

#import "ForumInfo.h"
#import "TopicInfo.h"

#define NSStringByTrimmed(x)	[(x) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

@implementation HTMLHelper

+ (NSArray *)convertForumList:(NSData *)htmlData {
	CXMLDocument *htmlParser = [[[CXHTMLDocument alloc] initWithXHTMLData:htmlData
																 encoding:NSUTF8StringEncoding
																  options:0
																	error:nil] autorelease];
	
    NSArray *resultNodes = [htmlParser nodesForXPath:kOSXDevXPathMain error:nil];
	NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:[resultNodes count]];
	
	for (CXMLElement *element in resultNodes) {
//		NSLog(@"content : %@", [element XMLString]);
		
		NSString *title = nil;
		NSString *desc = nil;
		NSString *href = nil;
		
		for (CXMLNode *node in [element children]) {
//			NSLog(@"length : %d", [NSStringByTrimmed([node stringValue]) length]);
			
			if ([NSStringByTrimmed([node stringValue]) length] != 0) {
				if ([[node name] isEqualToString:@"a"]) {
					title = NSStringByTrimmed([node stringValue]);
					href = [[(CXMLElement *)node attributeForName:@"href"] stringValue];
				}
				else if ([[node name] isEqualToString:@"text"]) {
					desc = NSStringByTrimmed([node stringValue]);
				}
				else {
					// do nothing...
				}
			}
		}
		
		ForumInfo *forumInfo = [ForumInfo forumInfoWithTitle:title desc:desc href:href];
		[menuList addObject:forumInfo];
	}
	
	return menuList;
}

+ (NSDictionary *)convertForumInfo:(NSData *)htmlData {
	// 일단 active topic 세팅을 하자.
	NSMutableDictionary *forumInfo = [NSMutableDictionary dictionaryWithDictionary:[self convertTopicInfo:htmlData]];
	
	[forumInfo setObject:[self convertForumList:htmlData] forKey:@"forum_list"];
	
	return forumInfo;
}

+ (NSDictionary *)convertTopicInfo:(NSData *)htmlData {
	NSMutableDictionary *topicInfo = [NSMutableDictionary dictionaryWithCapacity:0];
	
    CXMLDocument *htmlParser = [[[CXHTMLDocument alloc] initWithXHTMLData:htmlData
																 encoding:NSUTF8StringEncoding
																  options:0
																	error:nil] autorelease];
	
	// 일단 페이지를 잘라오기...
	NSArray *resultNodes = [htmlParser nodesForXPath:kOSXDevXPathForumHeaders error:nil];
	if ([resultNodes count] != 0) {
		NSMutableArray *sectionHeaderList = [NSMutableArray arrayWithCapacity:0];
		
		for (CXMLElement *element in resultNodes) {
			// 0번째가 section header
			NSString *sectionHeader = [element stringValue];
			[sectionHeaderList addObject:sectionHeader];
		}
		
		if ([sectionHeaderList count] > 0) {
			[topicInfo setObject:sectionHeaderList forKey:@"topic_header"];
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathPagination error:nil];
	if ([resultNodes count] != 0) {
		CXMLElement *pageElement = (CXMLElement *)[resultNodes objectAtIndex:0];
		
		NSArray *components = [[pageElement stringValue] componentsSeparatedByString:@"•"];
		NSMutableString	*infoString = [NSMutableString stringWithCapacity:0];
		for (NSInteger i = 0; i < [components count]; i++) {
			NSString *component = NSStringByTrimmed([components objectAtIndex:i]);
			if ([component hasPrefix:@"글타래:"] || [component hasSuffix:@"페이지"]) {
				[infoString appendFormat:@"%@   ", component];
			}
		}
		
		if ([infoString length] != 0) {
			[topicInfo setObject:infoString forKey:@"topic_info"];
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathTopicList error:nil];
	NSMutableArray *topicList = [NSMutableArray arrayWithCapacity:[resultNodes count]];
	
//	NSLog(@"count : %d", [resultNodes count]);
	for (CXMLElement *element in resultNodes) {
		CXMLNode *elementNode = [element childAtIndex:0];
		
		NSString *topicTitle = nil;
		NSString *topicDesc = nil;
		NSString *topicHref = nil;
		NSString *topicThreadCount = nil;
		NSString *topicRecentDesc = nil;
		
		NSString *tmpCountString = [[element childAtIndex:2] stringValue];
		topicThreadCount = [[tmpCountString componentsSeparatedByString:@" "] objectAtIndex:0];
		
		CXMLNode *tmpRecentInfoNode = [element childAtIndex:[element childCount] - 2];
		CXMLNode *recentInfoNode = [tmpRecentInfoNode childAtIndex:0];
		if ([recentInfoNode childCount] > 0) {
			topicRecentDesc = @"최근 글 - ";
		}
		
		for (NSInteger i = 1; i < [recentInfoNode childCount]; i++) {
			CXMLNode *childNode = [recentInfoNode childAtIndex:i];
			
			if ([NSStringByTrimmed([childNode stringValue]) length] == 0) {
				continue;
			}
			
			if (i == [recentInfoNode childCount] - 1) {
				NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
				dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"] autorelease];
				dateFormatter.AMSymbol = @"am";
				dateFormatter.PMSymbol = @"pm";
				dateFormatter.dateFormat = @"ccc MMM dd, yyyy h:mm a";
				
				NSDate *messageDate = [dateFormatter dateFromString:[childNode stringValue]];
				dateFormatter.AMSymbol = @"오전";
				dateFormatter.PMSymbol = @"오후";
				dateFormatter.dateFormat = @", yyyy.M.dd HH:mm";
				NSString *dateString = [dateFormatter stringFromDate:messageDate];
				
				topicRecentDesc = [topicRecentDesc stringByAppendingFormat:@"%@", dateString];
			}
			else {
				NSString *descString = NSStringByTrimmed([childNode stringValue]);
				if ([descString hasPrefix:@"올린이"] == NO) {
					topicRecentDesc = [topicRecentDesc stringByAppendingFormat:@"%@", descString];
				}
			}
		}
		
		for (CXMLNode *childNode in [elementNode children]) {
			if ([NSStringByTrimmed([childNode stringValue]) length] == 0) {
				continue;
			}
			
			if ([[childNode name] isEqualToString:@"a"] && 
				[[childNode XMLString] rangeOfString:@"viewtopic"].location != NSNotFound) {
				topicTitle = NSStringByTrimmed([childNode stringValue]);
				
				NSString *xmlString = [[childNode XMLString] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
				NSArray *components = [xmlString componentsSeparatedByString:@"\""];
				for (NSString *component in components) {
					if ([component rangeOfString:@"viewtopic"].location != NSNotFound) {
						topicHref = component;
						break;
					}
				}
			}
			
			if ([[childNode name] isEqualToString:@"a"] &&
				[[childNode XMLString] rangeOfString:@"memberlist"].location != NSNotFound) {
				topicDesc = NSStringByTrimmed([childNode stringValue]);
			}
			
			if ([[childNode name] isEqualToString:@"text"]) {
				if ([NSStringByTrimmed([childNode stringValue]) hasPrefix:@"» "]) {
					NSString *trimmed = [NSStringByTrimmed([childNode stringValue]) substringFromIndex:2];
					
					NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
					dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"] autorelease];
					dateFormatter.AMSymbol = @"am";
					dateFormatter.PMSymbol = @"pm";
					dateFormatter.dateFormat = @"ccc MMM dd, yyyy h:mm a";
					
					NSDate *messageDate = [dateFormatter dateFromString:trimmed];
					dateFormatter.AMSymbol = @"오전";
					dateFormatter.PMSymbol = @"오후";
					dateFormatter.dateFormat = @", yyyy.M.dd HH:mm";
					NSString *dateString = [dateFormatter stringFromDate:messageDate];
					//		[format setDateFormat:@"MMM dd, yyyy hh:mm"];
					// ex) » 금 3월 23, 2012 1:20 pm
					
					topicDesc = [topicDesc stringByAppendingString:dateString];
				}
				else {
					topicDesc = [topicDesc stringByAppendingString:NSStringByTrimmed([childNode stringValue])];
				}
			}
		}
		
		NSMutableDictionary *topicDic = [NSMutableDictionary dictionaryWithCapacity:0];
		
		if (topicDesc != nil) {
			[topicDic setObject:topicDesc forKey:@"topic_desc"];
		}
		
		if (topicTitle != nil) {
			[topicDic setObject:topicTitle forKey:@"topic_title"];
		}
		
		if (topicHref != nil) {
			[topicDic setObject:topicHref forKey:@"topic_href"];
		}
		
		if (topicThreadCount != nil) {
			[topicDic setObject:topicThreadCount forKey:@"topic_thread_count"];
		}
		
		if (topicRecentDesc != nil) {
			[topicDic setObject:topicRecentDesc forKey:@"topic_recent_desc"];
		}
		
		TopicInfo *topicInfo = [TopicInfo topicInfoWithTitle:topicTitle
														desc:topicDesc
														href:topicHref
												 threadCount:topicThreadCount
												  recentDesc:topicRecentDesc];
		[topicList addObject:topicInfo];
	}
	
	[topicInfo setObject:topicList forKey:@"topic_list"];
	
	return topicInfo;
}

+ (NSDictionary *)convertThreadInfo:(NSData *)htmlData {
	// 전반적인 thread를 converting하는 루틴은 시간 날때 변경할 예정.
	// template를 만들어 좀 더 예쁘게 꾸미고 보기 좋게 할 예정.
	
	NSMutableDictionary *threadInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	
	CXMLDocument *htmlParser = [[[CXHTMLDocument alloc] initWithXHTMLData:htmlData
																 encoding:NSUTF8StringEncoding
																  options:0
																	error:nil] autorelease];
	
	// 일단 페이지를 잘라오기...
	NSArray *resultNodes = [htmlParser nodesForXPath:kOSXDevXPathPagination error:nil];
	// 페이지 정보는 결국 header, footer 두개가 붙으므로
	// 아마도 두개가 나올 확률이 클 것이다.
	// 일단 첫번째 값만 사용하자.
	CXMLElement *pageElement = (CXMLElement *)[resultNodes objectAtIndex:0];
	
	NSArray *components = [[pageElement stringValue] componentsSeparatedByString:@"•"];
	NSMutableString	*infoString = [NSMutableString stringWithCapacity:0];
	for (NSInteger i = 0; i < [components count]; i++) {
		NSString *component = NSStringByTrimmed([components objectAtIndex:i]);
		if ([component hasPrefix:@"글:"] || [component hasSuffix:@"페이지"]) {
			[infoString appendFormat:@"%@   ", component];
		}
	}
	
	[threadInfo setValue:NSStringByTrimmed(infoString) forKey:@"thread_info"];
	
	NSMutableString *htmlString = [NSMutableString stringWithString:@"<html>"];//style='-webkit-text-size-adjust: none;'>"];
	
	resultNodes = [htmlParser nodesForXPath:@"//div[contains(@class, 'panel')]" error:nil];
	if ([resultNodes count] > 0) {
		for (CXMLElement *element in resultNodes) {
            if ([element attributeForName:@"id"] == nil) {
                // id가 있는 panel은 posting panel...
                [htmlString appendString:[element XMLString]];
            }
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathPostBody error:nil];
	if ([resultNodes count] > 0) {
		for (NSInteger i = 0; i < [resultNodes count]; i++) {
			CXMLElement *element = (CXMLElement *)[resultNodes objectAtIndex:i];
            
            for (CXMLNode *node in [element children]) {
                if ([[node name] isEqualToString:@"ul"] == NO) {
					NSString *xmlString = [node XMLString];
					if ([xmlString rangeOfString:@"<img"].location != NSNotFound) {
						if ([xmlString rangeOfString:@"/smile/"].location == NSNotFound && 
							[xmlString rangeOfString:@"/misc/"].location == NSNotFound && 
							[xmlString rangeOfString:@"/smilies/"].location == NSNotFound && 
							[xmlString rangeOfString:@"/imageset/"].location == NSNotFound) {
							xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<img" withString:@"<img style=\"width:100%;\""];
						}
						
						if ([xmlString rangeOfString:@"첨부파일"].location != NSNotFound) {
							xmlString = [xmlString stringByReplacingOccurrencesOfString:@"첨부파일" withString:@"<br /><li>첨부파일</li>"];
						}
					}
					
                    [htmlString appendString:xmlString];
                }
            }
			
			if (i != [resultNodes count] - 1) {
				[htmlString appendString:@"<hr style='border: 0; color: #000; background-color: #000; height: 1px;'/>"];
			}
		}
	}
	
	[htmlString appendString:@"</html>"];
	
	NSString *tmpString = htmlString;
	NSString *regEx = @"</?(?i:a|embed|object|frameset|frame|iframe|meta|link|input|dd|dt)(.|\n)*?>";
	NSRange r;
	while ((r = [tmpString rangeOfString:regEx options:NSRegularExpressionSearch]).location != NSNotFound) {
		tmpString = [tmpString stringByReplacingCharactersInRange:r withString:@""];
	}
	
	NSString *metaString = @"<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>";
	tmpString = [NSString stringWithFormat:@"%@%@", metaString, tmpString];
	
	[threadInfo setValue:[NSNumber numberWithInt:[resultNodes count]] forKey:@"thread_count"];
	[threadInfo setValue:tmpString forKey:@"thread_content"];
	
	return threadInfo;
}

+ (NSDictionary *)convertPostingInfo:(NSData *)htmlData {
	NSMutableDictionary *postingInfo = [NSMutableDictionary dictionaryWithCapacity:0];
	
    CXMLDocument *htmlParser = [[[CXHTMLDocument alloc] initWithXHTMLData:htmlData
																 encoding:NSUTF8StringEncoding
																  options:0
																	error:nil] autorelease];
	
	NSString *subject = nil;
	NSString *topicCurPostId = nil;
	NSString *lastClick = nil;
	NSString *creationTime = nil;
	NSString *formToken = nil;
	
	NSArray *resultNodes = [htmlParser nodesForXPath:kOSXDevXPathTopicCurPostId error:nil];
	if ([resultNodes count] != 0) {
		for (CXMLElement *element in resultNodes) {
			topicCurPostId = [[element attributeForName:@"value"] stringValue];
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathLastClick error:nil];
	if ([resultNodes count] != 0) {
		for (CXMLElement *element in resultNodes) {
			lastClick = [[element attributeForName:@"value"] stringValue];
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathCreationTime error:nil];
	if ([resultNodes count] != 0) {
		for (CXMLElement *element in resultNodes) {
			creationTime = [[element attributeForName:@"value"] stringValue];
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathFormToken error:nil];
	if ([resultNodes count] != 0) {
		for (CXMLElement *element in resultNodes) {
			formToken = [[element attributeForName:@"value"] stringValue];
		}
	}
	
	resultNodes = [htmlParser nodesForXPath:kOSXDevXPathPostingSubject error:nil];
	if ([resultNodes count] != 0) {
		for (CXMLElement *element in resultNodes) {
			subject = [[element attributeForName:@"value"] stringValue];
		}
	}
	
	if (subject) {
		[postingInfo setObject:subject forKey:@"subject"];
	}
	
	if (topicCurPostId) {
		[postingInfo setObject:topicCurPostId forKey:@"topic_cur_post_id"];
	}
	
	if (lastClick) {
		[postingInfo setObject:lastClick forKey:@"lastclick"];
	}
	
	if (creationTime) {
		[postingInfo setObject:creationTime forKey:@"creation_time"];
	}
	
	if (formToken) {
		[postingInfo setObject:formToken forKey:@"form_token"];
	}
	
	return postingInfo;
}

+ (NSString *)getSid:(NSData *)htmlData {
	CXMLDocument *htmlParser = [[[CXHTMLDocument alloc] initWithXHTMLData:htmlData
																 encoding:NSUTF8StringEncoding
																  options:0
																	error:nil] autorelease];
	
    NSArray *resultNodes = [htmlParser nodesForXPath:@"//a[contains(@href, 'sid')]" error:nil];
	
	NSString *sidString = nil;
	for (CXMLElement *element in resultNodes) {
		CXMLNode *attrNode = [element attributeForName:@"href"];
		NSString *urlString = [attrNode stringValue];
		
		sidString = [QueryHelper valueWithURLString:urlString token:@"sid"];
	}
	
	return sidString;
}

+ (BOOL)isValidData:(NSData *)htmlData requestType:(NetworkRequestType)requestType {
	NSString *dataString = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
	if ([dataString length] == 0) {
		return NO;
	}
	
	NSString *rangeString = nil;
	switch (requestType) {
		case NetworkRequestViewForum:
			rangeString = @"이 포럼에서 새 글타래를 올릴 수 있습니다.";
			break;
			
		case NetworkRequestLogin:
			rangeString = @"로그인 했습니다.";
			break;
			
		case NetworkRequestPosting:
			rangeString = @"글을 올렸습니다.";
			break;
			
		default:
			break;
	}
	
	NSRange dataRange = [dataString rangeOfString:rangeString];
	if (dataRange.location == NSNotFound) {
		return NO;
	}
	
	return YES;
}

@end

@implementation QueryHelper

+ (NSString *)valueWithURLString:(NSString *)urlString token:(NSString *)token {
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSString *queryString = [url query];
	if (queryString) {
		NSArray *params = [queryString componentsSeparatedByString:@"&"];
		for (int i = 0; i < [params count]; i++) {
			NSArray *keyValues = [[params objectAtIndex:i] componentsSeparatedByString:@"="];
			if ([keyValues count] >= 2) {
				NSString *key = [keyValues objectAtIndex:0];
				if ([key isEqualToString:token]) {
					NSString *value = [keyValues objectAtIndex:1];
					return value;
				}
			}
		}
	}
	
	return nil;
}

@end
