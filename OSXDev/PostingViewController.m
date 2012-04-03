//
//  PostingViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 BRID. All rights reserved.
//

#import "PostingViewController.h"

@interface PostingViewController ()

@end

@implementation PostingViewController

@synthesize forumId = _forumId;
@synthesize topicId = _topicId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumId:(NSInteger)forumId topicId:(NSInteger)topicId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		// topic id는 무조건 있어야 됨.
		// forum id는 -1일 경우에는 new topic, 그 이외에는 reply
		self.forumId = forumId;
		self.topicId = topicId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
