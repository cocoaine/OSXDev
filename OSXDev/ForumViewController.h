//
//  ForumViewController.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginViewController.h"

@interface ForumViewController : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, 
LoginViewControllerDelegate, NetworkObjectDelegate>

@property (retain, nonatomic) UITableView *forumTableView;
@property (retain, nonatomic) NetworkObject *networkObject;
@property (retain, nonatomic) NSArray *forumList;
@property (retain, nonatomic) NSArray *activeTopicList;
@property (retain, nonatomic) NSArray *sectionHeaderList;
//@property (retain, nonatomic) NSString *connectionIdentifier;
@property (retain, nonatomic) NSMutableDictionary *connectionInfo;

@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) UIBarButtonItem *indicatorItem;
@property (retain, nonatomic) UIBarButtonItem *refreshButton;

@property (nonatomic, retain) UIPopoverController *targetPopoverController;

@end
