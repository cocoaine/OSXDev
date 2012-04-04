//
//  PostingViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "PostingViewController.h"

@interface PostingViewController ()
- (void)clickCancel:(id)sender;
- (void)clickPosting:(id)sender;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)resizeViewControllerToFitScreen:(CGRect)bounds isON:(BOOL)isON;
@end

@implementation PostingViewController

@synthesize delegate = _delegate;
@synthesize forumId = _forumId;
@synthesize topicId = _topicId;
@synthesize networkObject = _networkObject;
@synthesize connectionIdentifier = _connectionIdentifier;
@synthesize topicCurPostId = _topicCurPostId;
@synthesize lastClick = _lastClick;
@synthesize creationTime = _creationTime;
@synthesize formToken = _formToken;
@synthesize subjectTextField = _subjectTextField;
@synthesize messageTextView = _messageTextView;
@synthesize forceCancel = _forceCancel;
@synthesize contentView = _contentView;
@synthesize keyboardBounds = _keyboardBounds;
@synthesize contentFrame = _contentFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumId:(NSInteger)forumId topicId:(NSInteger)topicId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.forceCancel = NO;
		
		// topic id는 무조건 있어야 됨.
		// forum id는 -1일 경우에는 new topic, 그 이외에는 reply
		self.forumId = forumId;
		self.topicId = topicId;
		
		if (self.topicId == -1) {
			[self.navigationItem setTitle:@"New Topic"];
		}
		else {
			[self.navigationItem setTitle:@"Post Reply"];
		}
		
		NetworkObject *networkObject = [[[NetworkObject alloc] initWithDelegate:self] autorelease];
		self.networkObject = networkObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIView *contentView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	contentView.backgroundColor = [UIColor whiteColor];
	
	self.contentView = contentView;
	
	[self.view addSubview:self.contentView];
	
	CGRect frameRect = CGRectZero;
	frameRect.origin.x = 5.f;
	frameRect.origin.y = 5.f;
	frameRect.size.width = self.view.bounds.size.width - 10.f;
	frameRect.size.height = 20.f;
	
	UITextField *textField = [[[UITextField alloc] initWithFrame:frameRect] autorelease];
	textField.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth);
	textField.backgroundColor = [UIColor clearColor];
	textField.textColor = [UIColor blackColor];
	textField.delegate = self;
	textField.font = [UIFont boldSystemFontOfSize:18.f];
	
	textField.placeholder = @"제목을 입력하세요.";
	textField.returnKeyType = UIReturnKeyNext;
	
	self.subjectTextField = textField;
	
	[self.contentView addSubview:self.subjectTextField];
	
	frameRect.origin.x = 0.f;
	frameRect.origin.y = self.subjectTextField.frame.origin.y + self.subjectTextField.frame.size.height + 5.f;
	frameRect.size.width = self.view.bounds.size.width;
	frameRect.size.height = self.contentView.frame.size.height - frameRect.origin.y - 44.f;
	
	UITextView *textView = [[[UITextView alloc] initWithFrame:frameRect] autorelease];
	textView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	textView.backgroundColor = [UIColor clearColor];
	textView.textColor = [UIColor blackColor];
	textView.delegate = self;
	textView.font = [UIFont systemFontOfSize:16.f];
	
	textView.returnKeyType = UIReturnKeyDefault;
	
	frameRect.origin.x = 0.f;
	frameRect.size.height = 1.f;
	
	UIView *separatorTop = [[[UIView alloc] initWithFrame:frameRect] autorelease];
	separatorTop.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.7f];
	separatorTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	[self.contentView addSubview:separatorTop];
	
	frameRect.origin.y += 1.f;
	
	UIView *separatorBottom = [[[UIView alloc] initWithFrame:frameRect] autorelease];
	separatorBottom.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.5f];
	separatorBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	[self.contentView addSubview:separatorBottom];
	
	self.messageTextView = textView;
	
	[self.contentView addSubview:self.messageTextView];
	
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				   target:self
																				   action:@selector(clickCancel:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	
	UIBarButtonItem *postingButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																					target:self
																					action:@selector(clickPosting:)] autorelease];
	[self.navigationItem setRightBarButtonItem:postingButton animated:YES];
	
	if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusLoggedIn) {
		self.navigationController.view.userInteractionEnabled = NO;
		[SVProgressHUD showInView:self.view status:@"글쓰기 불러오는 중..."];
		self.connectionIdentifier = [self.networkObject postingDataWithForumId:self.forumId
																	   topicId:self.topicId];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification 
											   object:nil];	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.forceCancel) {
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusNotLoggedIn) {
			LoginViewController *viewController = [[[LoginViewController alloc] initWithNibName:nil
																						 bundle:nil] autorelease];
			viewController.delegate = self;
			
			UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				navController.modalPresentationStyle = UIModalPresentationFormSheet;
			}
			
			[self.navigationController presentModalViewController:navController animated:NO];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)dealloc
{
    self.delegate = nil;
	
	self.networkObject.delegate = nil;
	[self.networkObject closeAllConnections];
	
	[_networkObject release];
	[_connectionIdentifier release];
	[_topicCurPostId release];
	[_lastClick release];
	[_creationTime release];
	[_formToken release];
	[_subjectTextField release];
	[_messageTextView release];
	[_contentView release];
	
    [super dealloc];
}

// MARK: -
// MARK: << Private methods >>
- (void)clickCancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)clickPosting:(id)sender {
	self.navigationController.view.userInteractionEnabled = NO;
	[SVProgressHUD showInView:self.view status:@"글 등록중..."];
	self.connectionIdentifier= [self.networkObject postingWithSubject:self.subjectTextField.text
															  message:self.messageTextView.text
															  forumId:self.forumId
															  topicId:self.topicId
													   topicCurPostId:self.topicCurPostId
															lastClick:self.lastClick
														 creationTime:self.creationTime
															formToken:self.formToken];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.keyboardBounds = [self.view convertRect:keyboardRect fromView:nil];
	
	self.contentFrame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
	[self resizeViewControllerToFitScreen:self.keyboardBounds isON:YES];
	
}

- (void)keyboardWillHide:(NSNotification *)notification {
	self.keyboardBounds = CGRectZero;
	
	[self resizeViewControllerToFitScreen:self.keyboardBounds isON:NO];
}

- (void)resizeViewControllerToFitScreen:(CGRect)bounds isON:(BOOL)isON {
	// Needs adjustment for portrait orientation!
	CGRect frame = self.contentView.frame;
	
	if (isON) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			frame.size.height -= bounds.size.height;
		}
		else {
			frame.size.height -= (bounds.size.height - 140.f);
		}
	}
	else {
		frame = self.contentFrame;
	}
	
	[UIView animateWithDuration:0.3f 
						  delay:0.f 
						options:UIViewAnimationOptionBeginFromCurrentState 
					 animations:^{
						 self.contentView.frame = frame;
					 }
					 completion:^(BOOL finished){
						 // do nothing...
					 }];
}

// MARK: -
// MARK: << UIAlertViewDelegate >>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex; {
	if (alertView.title == @"불러오기 오류") {
		[self clickCancel:nil];
	}
}

// MARK: -
// MARK: << LoginViewControllerDelegate >>
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)controller {
	[controller dismissModalViewControllerAnimated:YES];
	
	if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusLoggedIn) {
		self.navigationController.view.userInteractionEnabled = NO;
		[SVProgressHUD showInView:self.view status:@"글쓰기 불러오는 중..."];
		self.connectionIdentifier = [self.networkObject postingDataWithForumId:self.forumId
																	   topicId:self.topicId];
	}
}

- (void)loginViewControllerDidCancel:(LoginViewController *)controller {
	NSLog(@"loginViewControllerDidCancel");
	self.forceCancel = YES;
	
	[controller dismissModalViewControllerAnimated:NO];
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	self.navigationController.view.userInteractionEnabled = YES;
	[SVProgressHUD dismiss];
	
	if (requestType == NetworkRequestPostingData) {
		NSDictionary *postingInfo = [HTMLHelper convertPostingInfo:data];
		
		if ([postingInfo count] == 0) {
			// 아무런 포스팅 밸류가 없으면
			// 무조건 오류로 간주하자.
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"불러오기 오류"
																message:@"글쓰기 불러오기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
															   delegate:self
													  cancelButtonTitle:@"확인"
													  otherButtonTitles:nil, nil];
			
			[alertView show];
			[alertView release];
			
			return;
		}
		
		self.topicCurPostId = [postingInfo objectForKey:@"topic_cur_post_id"];
		self.lastClick = [postingInfo objectForKey:@"lastclick"];
		self.creationTime = [postingInfo objectForKey:@"creation_time"];
		self.formToken = [postingInfo objectForKey:@"form_token"];
		
		NSString *subject = [postingInfo objectForKey:@"subject"];
		if (subject && [subject length] != 0) {
			[self.subjectTextField setText:subject];
			[self.subjectTextField setEnabled:NO];
			
			[self.messageTextView becomeFirstResponder];
		}
		else {
			[self.subjectTextField becomeFirstResponder];
		}
	}
	else if (requestType == NetworkRequestPosting) {
		if (self.delegate) {
			[self.delegate postingViewControllerDidFinishPosting:self];
		}
	}
	else {
		
	}
	
	self.connectionIdentifier = nil;
}

- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error {
	self.navigationController.view.userInteractionEnabled = YES;
	[SVProgressHUD dismiss];
	
	if (requestType == NetworkRequestPostingData) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"불러오기 오류"
															message:@"글쓰기 불러오기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		
		[alertView show];
		[alertView release];
	}
	else if (requestType == NetworkRequestPosting) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"글쓰기 오류"
															message:@"글쓰기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		
		[alertView show];
		[alertView release];
	}
	else {
		
	}
	
	self.connectionIdentifier = nil;
}

@end
