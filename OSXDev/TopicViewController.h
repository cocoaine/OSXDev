//
//  TopicViewController.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PostingViewController.h"
#import "LoginViewController.h"
#import "ForumInfo.h"

@interface TopicViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, NetworkObjectDelegate, PostingViewControllerDelegate, LoginViewControllerDelegate>

@property (retain, nonatomic) UITableView *topicTableView;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) NetworkObject *networkObject;
@property (retain, nonatomic) NSString *forumTitle;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger totalPage;
@property (retain, nonatomic) NSArray *topicList;
@property (assign, nonatomic) NSInteger forumId;
@property (retain, nonatomic) NSString *connectionIdentifier;
@property (assign, nonatomic) NSInteger start;
@property (retain, nonatomic) UIBarButtonItem *indicatorItem;
@property (retain, nonatomic) UIBarButtonItem *prevButton;
@property (retain, nonatomic) UIBarButtonItem *nextButton;
@property (retain, nonatomic) UIBarButtonItem *refreshButton;
@property (retain, nonatomic) UIBarButtonItem *gotoButton;
@property (retain, nonatomic) UIBarButtonItem *writeButton;
@property (retain, nonatomic) UILabel *infoLabel;
@property (retain, nonatomic) UITextField *pageTextField;
@property (retain, nonatomic) NSString *infoString;
@property (assign, nonatomic) BOOL endOfTopic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumInfo:(ForumInfo *)forumInfo;

@end
