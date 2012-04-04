//
//  BrowserViewController.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 30..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate>

@property (retain, nonatomic) UIWebView *browserWebView;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) UIBarButtonItem *indicatorItem;
@property (retain, nonatomic) UIBarButtonItem *prevPageItem;
@property (retain, nonatomic) UIBarButtonItem *nextPageItem;
@property (retain, nonatomic) UIBarButtonItem *refreshPageItem;
@property (retain, nonatomic) UIBarButtonItem *stopPageItem;
@property (retain, nonatomic) UIBarButtonItem *externalLinkItem;
@property (retain, nonatomic) UIBarButtonItem *blankSpace;
@property (retain, nonatomic) NSURL *requestURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)url;

@end
