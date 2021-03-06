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
@synthesize contentView = _contentView;
@synthesize keyboardBounds = _keyboardBounds;
@synthesize contentFrame = _contentFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumId:(NSInteger)forumId topicId:(NSInteger)topicId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		// topic id는 무조건 있어야 됨.
		// forum id는 -1일 경우에는 new topic, 그 이외에는 reply
		self.forumId = forumId;
		self.topicId = topicId;
		
		if (self.topicId == -1) {
			[self.navigationItem setTitle:@"새글 올리기"];
		}
		else {
			[self.navigationItem setTitle:@"댓글 달기"];
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
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		CGFloat posY = 100.f;
		if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
			posY = 60.f;
		}
		
		[SVProgressHUD showInView:self.view
						   status:@"글쓰기 불러오는 중..." 
				 networkIndicator:NO 
							 posY:posY 
						 maskType:SVProgressHUDMaskTypeClear];
	}
	else {
		[SVProgressHUD showInView:self.view 
						   status:@"글쓰기 불러오는 중..." 
						 maskType:SVProgressHUDMaskTypeClear];
	}
	
	self.connectionIdentifier = [self.networkObject postingDataWithForumId:self.forumId
																   topicId:self.topicId];
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
	if ([[self.subjectTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || 
		[[self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
		NSString *alertMessage = nil;
		if ([[self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
			alertMessage = @"글 내용이 비어있습니다.\n다시 한 번 확인해주세요.";
		}
		else {
			alertMessage = @"제목이 비어있습니다.\n다시 한 번 확인해주세요.";
		}
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"글쓰기 오류"
															message:alertMessage
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		alertView.tag = kOSXDevAlertTagError;
		
		[alertView show];
		[alertView release];
		
		return;
	}
	
	[self.subjectTextField resignFirstResponder];
	[self.messageTextView resignFirstResponder];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		CGFloat posY = 100.f;
		if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
			posY = 60.f;
		}
		
		[SVProgressHUD showInView:self.view status:@"글 등록 중..." networkIndicator:NO posY:posY maskType:SVProgressHUDMaskTypeClear];
	}
	else {
		[SVProgressHUD showInView:self.view status:@"글 등록 중..." maskType:SVProgressHUDMaskTypeClear];
	}
	
	NSString *signature = nil;
	if ([[NSUserDefaults standardUserDefaults] stringForKey:kOSXDevSignatureValue]) {
		signature = [[[NSUserDefaults standardUserDefaults] stringForKey:kOSXDevSignatureValue]
					 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	
	NSString *message = self.messageTextView.text;
	if (signature != nil) {
		if ([signature length] > 0) {
			NSLog(@"message with signature...");
			message = [message stringByAppendingFormat:@"\n\n%@", signature];
		}
		else {
			// only message
			NSLog(@"only message");
		}
	}
	
	self.connectionIdentifier= [self.networkObject postingWithSubject:self.subjectTextField.text
															  message:message
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
	if (alertView.tag == kOSXDevAlertTagErrorLoading) {
		[self clickCancel:nil];
	}
	else {
		if (self.topicId == -1) {
			[self.subjectTextField becomeFirstResponder];
		}
		else {
			[self.messageTextView becomeFirstResponder];
		}
	}
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	if (requestType == NetworkRequestPostingData) {
		NSDictionary *postingInfo = [HTMLHelper convertPostingInfo:data];
		if ([postingInfo count] == 0) {
			// 로그인된 상태에서 포스팅 오류가 나면 쿠키 문제?
			// 로그인 한 번 더 시도하기.
			NSLog(@"########## retry login...");
			NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
			for (NSHTTPCookie *cookie in [storage cookies]) {
				[storage deleteCookie:cookie];
			}
			
			[UserInfo sharedInfo].sid = nil;
			
			[self.networkObject login];
			
			return;
		}
		
		[SVProgressHUD dismiss];
		
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
		[SVProgressHUD dismiss];
		
		if ([HTMLHelper isValidData:data requestType:requestType]) {
			if (self.delegate) {
				[self.delegate postingViewControllerDidFinishPosting:self];
			}
		}
		else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"글쓰기 오류"
																message:@"글쓰기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
															   delegate:self
													  cancelButtonTitle:@"확인"
													  otherButtonTitles:nil, nil];
			alertView.tag = kOSXDevAlertTagError;
			
			[alertView show];
			[alertView release];
		}
	}
	else if (requestType == NetworkRequestLogin) {
		if ([HTMLHelper isValidData:data requestType:requestType] == NO) {
			// 이땐 정말 최종적인 글쓰기 오류 간주.
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"불러오기 오류"
																message:@"글쓰기 불러오기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
															   delegate:self
													  cancelButtonTitle:@"확인"
													  otherButtonTitles:nil, nil];
			alertView.tag = kOSXDevAlertTagErrorLoading;
			
			[alertView show];
			[alertView release];
		}
		else {
			NSLog(@"########## login success, try to get posting data");
			self.connectionIdentifier = [self.networkObject postingDataWithForumId:self.forumId
																		   topicId:self.topicId];
		}
	}
	else {
		
	}
	
	self.connectionIdentifier = nil;
}

- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error {
	[SVProgressHUD dismiss];
	
	if (requestType == NetworkRequestPostingData || requestType == NetworkRequestLogin) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"불러오기 오류"
															message:@"글쓰기 불러오기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		alertView.tag = kOSXDevAlertTagErrorLoading;
		
		[alertView show];
		[alertView release];
	}
	else if (requestType == NetworkRequestPosting) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"글쓰기 오류"
															message:@"글쓰기에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		alertView.tag = kOSXDevAlertTagError;
		
		[alertView show];
		[alertView release];
	}
	else {
		
	}
	
	self.connectionIdentifier = nil;
}

@end
