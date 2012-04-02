//
//  ThreadViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "ThreadViewController.h"

#import "BrowserViewController.h"

@interface ThreadViewController ()
- (void)clickPrevious:(id)sender;
- (void)clickNext:(id)sender;
- (void)clickRefresh:(id)sender;
- (void)clickGoto:(id)sender;
- (void)clickWrite:(id)sender;
@end

@implementation ThreadViewController

@synthesize detailWebView = _detailWebView;
@synthesize indicatorView = _indicatorView;
@synthesize networkObject = _networkObject;
@synthesize page = _page;
@synthesize totalPage = _totalPage;
@synthesize forumId = _forumId;
@synthesize topicId = _topicId;
@synthesize connectionIdentifier = _connectionIdentifier;
@synthesize start = _start;
@synthesize indicatorItem = _indicatorItem;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize refreshButton = _refreshButton;
@synthesize gotoButton = _gotoButton;
@synthesize writeButton = _writeButton;
@synthesize infoLabel = _infoLabel;
@synthesize pageTextField = _pageTextField;
@synthesize infoString = _infoString;
@synthesize endOfThread = _endOfThread;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topicInfo:(NSDictionary *)topicInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.page = 1;
		self.totalPage = 1;
		self.start = 0;
		self.endOfThread = NO;
		
//		NSString *title = [topicInfo objectForKey:@"topic_title"];
		NSString *href = [topicInfo objectForKey:@"topic_href"];
		
		self.forumId = [QueryHelper identifierWithURLString:href token:@"f"];
		self.topicId = [QueryHelper identifierWithURLString:href token:@"t"];
		NSLog(@"self.forumId : %d", self.forumId);
		NSLog(@"self.topicId : %d", self.topicId);
		
		NetworkObject *networkObject = [[[NetworkObject alloc] initWithDelegate:self] autorelease];
		self.networkObject = networkObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor clearColor];
	
	UIWebView *webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
	webView.autoresizingMask = UIViewAutoresizingFlexibleAll;
	webView.dataDetectorTypes = UIDataDetectorTypeLink;
	webView.delegate = self;
	self.detailWebView = webView;
	
	[self.view addSubview:self.detailWebView];
	
	UIActivityIndicatorViewStyle indicatorViewStyle;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	}
	else {
		indicatorViewStyle = UIActivityIndicatorViewStyleGray;
	}
	
	UIActivityIndicatorView *indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorViewStyle] autorelease];
	indicatorView.hidesWhenStopped = YES;
	self.indicatorView = indicatorView;
	
	UIBarButtonItem *indicatorItem = [[[UIBarButtonItem alloc] initWithCustomView:self.indicatorView] autorelease];
	self.indicatorItem = indicatorItem;
	
	UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																					target:self
																					action:@selector(clickRefresh:)] autorelease];
	self.refreshButton = refreshButton;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UILabel *infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 250.f, self.navigationController.toolbar.frame.size.height)] autorelease];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.font = [UIFont boldSystemFontOfSize:15.f];
		
		infoLabel.textColor = [UIColor grayColor];
		infoLabel.shadowColor = [UIColor whiteColor];
		infoLabel.shadowOffset = CGSizeMake(0.f, 1.f);
		
		infoLabel.textAlignment = UITextAlignmentCenter;
		infoLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
		self.infoLabel = infoLabel;
	}
	
	UIBarButtonItem *prevButton = [[[UIBarButtonItem alloc] initWithTitle:@"<"
																	style:UIBarButtonItemStylePlain
																   target:self 
																   action:@selector(clickPrevious:)] autorelease];
	prevButton.enabled = NO;
	self.prevButton = prevButton;
	
	UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] initWithTitle:@">"
																	style:UIBarButtonItemStylePlain
																   target:self 
																   action:@selector(clickNext:)] autorelease];
	nextButton.enabled = NO;
	self.nextButton = nextButton;
	
	UIBarButtonItem *gotoButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self 
																				 action:@selector(clickGoto:)] autorelease];
	gotoButton.enabled = NO;
	self.gotoButton = gotoButton;
	
	UIBarButtonItem *writeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				  target:self 
																				  action:@selector(clickWrite:)] autorelease];
	writeButton.enabled = NO;
	self.writeButton = writeButton;
	
	UIBarButtonItem *blankSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[self setToolbarItems:[NSArray arrayWithObjects:prevButton, blankSpace, nextButton, blankSpace, gotoButton, blankSpace, writeButton, nil]
					 animated:YES];
		
	}
	else {
		UIBarButtonItem *tmpInfoLabelItem = [[[UIBarButtonItem alloc] initWithCustomView:self.infoLabel] autorelease];
		
		[self setToolbarItems:[NSArray arrayWithObjects:prevButton, blankSpace, nextButton, blankSpace, tmpInfoLabelItem, blankSpace, gotoButton, blankSpace, writeButton, nil]
					 animated:YES];
	}
	
	if (self.forumId != -1 && self.topicId != -1) {
		[self.indicatorView startAnimating];
		[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
		
		self.connectionIdentifier = [self.networkObject threadListWithForumId:self.forumId
																	  topicId:self.topicId
																		start:self.start];
	}
	else {
		// error...
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if(fromInterfaceOrientation == UIInterfaceOrientationPortrait){
		[self.detailWebView stringByEvaluatingJavaScriptFromString:@"rotate(0)"];	
	}
	else{
		[self.detailWebView stringByEvaluatingJavaScriptFromString:@"rotate(1)"];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.detailWebView.frame = self.view.bounds;
}

- (void)dealloc
{
	self.networkObject.delegate = nil;
	[_networkObject closeAllConnections];
	
	self.detailWebView.delegate = nil;
	[_detailWebView release];
	
	[_indicatorView release];
	[_networkObject release];
	[_connectionIdentifier release];
	[_indicatorItem release];
	[_prevButton release];
	[_nextButton release];
	[_refreshButton release];
	[_gotoButton release];
	[_writeButton release];
	[_infoLabel release];
	[_pageTextField release];
	[_infoString release];
    
    [super dealloc];
}

// MARK: -
// MARK: << Private methods >>
- (void)clickPrevious:(id)sender {
	if (self.start <= 0) {
		return;
	}
	
	if (self.connectionIdentifier) {
		[self.networkObject closeConnection:self.connectionIdentifier];
	}
	
	self.page -= 1;
	self.start -= kOSXDevThreadMaxCount;
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	self.connectionIdentifier = [self.networkObject threadListWithForumId:self.forumId
																  topicId:self.topicId
																	start:self.start];
}

- (void)clickNext:(id)sender {
	if (self.start % kOSXDevThreadMaxCount != 0 || self.endOfThread) {
		return;
	}
	
	if (self.connectionIdentifier) {
		[self.networkObject closeConnection:self.connectionIdentifier];
	}
	
	self.page += 1;
	self.start += kOSXDevThreadMaxCount;
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	self.connectionIdentifier = [self.networkObject threadListWithForumId:self.forumId
																  topicId:self.topicId
																	start:self.start];
}

- (void)clickRefresh:(id)sender {
	if (self.connectionIdentifier) {
		[self.networkObject closeConnection:self.connectionIdentifier];
	}
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	self.connectionIdentifier = [self.networkObject threadListWithForumId:self.forumId
																  topicId:self.topicId
																	start:self.start];
}

- (void)clickGoto:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"페이지 이동"
														message:@"이동하려는 페이지 번호를 선택하세요.\n\n\n" 
													   delegate:self
											  cancelButtonTitle:@"취소"
											  otherButtonTitles:@"확인", nil];
	
	if (self.pageTextField) {
		[self.pageTextField removeFromSuperview];
		self.pageTextField = nil;
	}
	
	UITextField *pageTextField = [[[UITextField alloc] initWithFrame:CGRectMake(12.f, -100.f, 260.f, 25.f)] autorelease]; 
	pageTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	pageTextField.backgroundColor = [UIColor whiteColor];
	pageTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	pageTextField.keyboardType = UIKeyboardTypeNumberPad;
	pageTextField.placeholder = self.infoString;
	
	self.pageTextField = pageTextField;
	
	[alertView addSubview:self.pageTextField];
	
	[alertView show];
	[alertView release];
	
	[self.pageTextField becomeFirstResponder];
}

- (void)clickWrite:(id)sender {
	
}

// MARK: -
// MARK: << UIWebViewDelegate >>
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"request url : %@", [[request URL] absoluteString]);
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		BrowserViewController *viewController = [[[BrowserViewController alloc] 
												  initWithNibName:nil bundle:nil url:[request URL]] autorelease];
		[self.navigationController pushViewController:viewController animated:YES];
		
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.indicatorView stopAnimating];
}

// MARK: -
// MARK: << UIAlertViewDelegate >>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex; {
	if (alertView.title == @"페이지 이동 오류") {
		[self clickGoto:nil];
	}
	
	if (buttonIndex == 1) {
		// 이동...
		NSInteger page = [[self.pageTextField text] integerValue];
		if (page > self.totalPage || page < 1) {
			UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"페이지 이동 오류"
																	 message:@"페이지를 다시 입력하세요." 
																	delegate:self
														   cancelButtonTitle:nil
														   otherButtonTitles:@"확인", nil];
			
			[errorAlertView show];
			[errorAlertView release];
		}
		else {
			self.page = page;
			self.start = ((page - 1) * kOSXDevThreadMaxCount);
			
			[self.indicatorView startAnimating];
			[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
			self.connectionIdentifier = [self.networkObject threadListWithForumId:self.forumId
																		  topicId:self.topicId
																			start:self.start];
		}
	}
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	[self.navigationItem setRightBarButtonItem:self.refreshButton animated:YES];
	[self.indicatorView stopAnimating];
	
	if (requestType == NetworkRequestViewTopic) {
		NSDictionary *threadInfo = [HTMLHelper convertThreadInfo:data];
		
		NSString *htmlString = [threadInfo objectForKey:@"thread_content"];
		self.infoString = [threadInfo objectForKey:@"thread_info"];
		NSInteger count = [[threadInfo objectForKey:@"thread_count"] integerValue];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.infoLabel.text = self.infoString;
		}
		
		if (self.start < kOSXDevThreadMaxCount) {
			[self.prevButton setEnabled:NO];
		}
		else {
			[self.prevButton setEnabled:YES];
		}
		
		self.endOfThread = NO;
		
		NSArray *components = [self.infoString componentsSeparatedByString:@"개"];
		self.totalPage = [[components objectAtIndex:1] integerValue];
		[self.navigationItem setTitle:[NSString stringWithFormat:@"%d페이지 / %d페이지", self.page, self.totalPage]];
		
		if (count < kOSXDevThreadMaxCount) {
			self.endOfThread = YES;
			[self.nextButton setEnabled:NO];
		}
		else {
			if (count == kOSXDevThreadMaxCount && self.page == self.totalPage) {
				[self.nextButton setEnabled:NO];
			}
			else {
				[self.nextButton setEnabled:YES];
			}
		}
		
		if ([self.infoString rangeOfString:@"글: 10"].location != NSNotFound) {
			// 일단 한 페이지에 글이 10개 기준으로 10개만 가져오고 10개만 있는 상황일 때...
			[self.prevButton setEnabled:NO];
			[self.nextButton setEnabled:NO];
		}
		
		self.gotoButton.enabled = YES;
		self.writeButton.enabled = YES;
		
		[self.detailWebView loadHTMLString:htmlString
								   baseURL:[NSURL URLWithString:kOSXDevURLPrefix]];
	}
	else {
		
	}
	
	self.connectionIdentifier = nil;
}

- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error {
	
}

@end
