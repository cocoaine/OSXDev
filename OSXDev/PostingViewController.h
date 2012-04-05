//
//  PostingViewController.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostingViewControllerDelegate;

@interface PostingViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, NetworkObjectDelegate>

@property (assign, nonatomic) id <PostingViewControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger forumId;
@property (assign, nonatomic) NSInteger topicId;
@property (retain, nonatomic) NetworkObject *networkObject;
@property (retain, nonatomic) NSString *connectionIdentifier;

@property (retain, nonatomic) NSString *topicCurPostId;
@property (retain, nonatomic) NSString *lastClick;
@property (retain, nonatomic) NSString *creationTime;
@property (retain, nonatomic) NSString *formToken;

@property (retain, nonatomic) UITextField *subjectTextField;
@property (retain, nonatomic) UITextView *messageTextView;

@property (retain, nonatomic) UIView *contentView;
@property (assign, nonatomic) CGRect keyboardBounds;
@property (assign, nonatomic) CGRect contentFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumId:(NSInteger)forumId topicId:(NSInteger)topicId;

@end

@protocol PostingViewControllerDelegate <NSObject>
@required
- (void)postingViewControllerDidFinishPosting:(PostingViewController *)controller;
@end
