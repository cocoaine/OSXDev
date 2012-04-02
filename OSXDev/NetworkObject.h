//
//  NetworkObject.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkHeader.h"

@interface NetworkObject : NSObject

@property (assign, nonatomic) __weak id delegate;
@property (retain, nonatomic) NSMutableDictionary *connections;
@property (retain, nonatomic) NSArray *cookies;
@property (retain, nonatomic) NSString *sid;

- (id)initWithDelegate:(id <NetworkObjectDelegate>)aDelegate;

// Connection methods
- (NSUInteger)numberOfConnections;
- (NSArray *)connectionIdentifiers;
- (void)closeConnection:(NSString *)connectionIdentifier;
- (void)closeAllConnections;

// API Lists...
- (NSString *)forumList;
- (NSString *)topicListWithForumId:(NSInteger)forumId start:(NSInteger)start;
- (NSString *)threadListWithForumId:(NSInteger)forumId topicId:(NSInteger)topicId start:(NSInteger)start;
- (NSString *)loginWithId:(NSString *)loginId password:(NSString *)password;

@end
