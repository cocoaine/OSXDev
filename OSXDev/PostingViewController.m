//
//  PostingViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 BRID. All rights reserved.
//

#import "PostingViewController.h"

@interface PostingViewController ()
- (void)clickCancel:(id)sender;
- (void)clickPosting:(id)sender;
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
@synthesize postingTableView = _postingTableView;
@synthesize subjectTextField = _subjectTextField;
@synthesize messageTextView = _messageTextView;

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
	
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
														   style:UITableViewStylePlain] autorelease];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleAll;
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.allowsSelection = NO;
	
	self.postingTableView = tableView;
	
	[self.view addSubview:tableView];
	
	[self.postingTableView reloadData];
	
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				   target:self
																				   action:@selector(clickCancel:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
	
	UIBarButtonItem *postingButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																					target:self
																					action:@selector(clickPosting:)] autorelease];
	[self.navigationItem setRightBarButtonItem:postingButton animated:YES];
	
	// just for test
	self.navigationController.view.userInteractionEnabled = NO;
	[SVProgressHUD showInView:self.view status:@"글쓰기 불러오는 중..."];
	self.connectionIdentifier = [self.networkObject postingDataWithForumId:self.forumId
																   topicId:self.topicId];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.subjectTextField becomeFirstResponder];
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
	[_postingTableView release];
	[_subjectTextField release];
	[_messageTextView release];
	
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

// MARK: -
// MARK: << UITableView >>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0.f;
	switch (indexPath.row) {
		case 0:
		{
			height = tableView.rowHeight;
		}
			break;
			
		case 1:
		{
			height = self.postingTableView.bounds.size.height;
		}
			break;
			
		default:
			break;
	}
	
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:cellIdentifier] autorelease];
    }
	
	NSLog(@"self.postingTableView.bounds.size.width : %f", self.postingTableView.bounds.size.width);
	
	switch (indexPath.row) {
		case 0:
		{
			if (self.subjectTextField == nil) {
				CGRect textFieldRect = CGRectZero;
				textFieldRect.origin.x = 0.f;
				textFieldRect.origin.y = 0.f;
				textFieldRect.size.width = self.postingTableView.bounds.size.width - 20.f;
				textFieldRect.size.height = 20.f;
				
				UITextField *textField = [[[UITextField alloc] initWithFrame:textFieldRect] autorelease];
				textField.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
				textField.backgroundColor = [UIColor clearColor];
				textField.textColor = [UIColor blackColor];
				textField.delegate = self;
				textField.font = [UIFont boldSystemFontOfSize:18.f];
				
				textField.placeholder = @"제목을 입력하세요.";
				textField.returnKeyType = UIReturnKeyNext;
				
				self.subjectTextField = textField;
			}
			
			cell.accessoryView = self.subjectTextField;
		}
			break;
			
		case 1:
		{
			if (self.messageTextView == nil) {
				CGRect textViewdRect = CGRectZero;
				textViewdRect.origin.x = 0.f;
				textViewdRect.origin.y = 0.f;
				textViewdRect.size.width = self.postingTableView.bounds.size.width;
				textViewdRect.size.height = self.postingTableView.bounds.size.height;
				
				UITextView *textView = [[[UITextView alloc] initWithFrame:textViewdRect] autorelease];
				textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
				textView.backgroundColor = [UIColor clearColor];
				textView.textColor = [UIColor blackColor];
				textView.delegate = self;
				textView.font = [UIFont systemFontOfSize:15.f];
				
				textView.returnKeyType = UIReturnKeyDone;
				
				self.messageTextView = textView;
			}
			
			cell.accessoryView = self.messageTextView;
		}
			break;
			
		default:
			break;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.postingTableView) {
		[self.subjectTextField resignFirstResponder];
		[self.messageTextView resignFirstResponder];
	}
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	self.navigationController.view.userInteractionEnabled = YES;
	[SVProgressHUD dismiss];
	
	if (requestType == NetworkRequestPostingData) {
		NSDictionary *postingInfo = [HTMLHelper convertPostingInfo:data];
		NSLog(@"postingInfo : %@", postingInfo);
		
		self.topicCurPostId = [postingInfo objectForKey:@"topic_cur_post_id"];
		self.lastClick = [postingInfo objectForKey:@"lastclick"];
		self.creationTime = [postingInfo objectForKey:@"creation_time"];
		self.formToken = [postingInfo objectForKey:@"form_token"];
		
		NSString *subject = [postingInfo objectForKey:@"subject"];
		if (subject && [subject length] != 0) {
			[self.subjectTextField setText:subject];
			[self.subjectTextField setEnabled:NO];
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
