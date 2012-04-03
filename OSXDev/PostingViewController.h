//
//  PostingViewController.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 BRID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostingViewController : UIViewController

@property (assign, nonatomic) NSInteger forumId;
@property (assign, nonatomic) NSInteger topicId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumId:(NSInteger)forumId topicId:(NSInteger)topicId;

@end
