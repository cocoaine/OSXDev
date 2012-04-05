//
//  TopicViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "TopicViewController.h"

#import "ThreadViewController.h"

@interface TopicViewController ()
- (void)clickPrevious:(id)sender;
- (void)clickNext:(id)sender;
- (void)clickRefresh:(id)sender;
- (void)clickGoto:(id)sender;
- (void)clickWrite:(id)sender;
@end

@implementation TopicViewController

@synthesize topicTableView = _topicTableView;
@synthesize indicatorView = _indicatorView;
@synthesize networkObject = _networkObject;
@synthesize forumTitle = _forumTitle;
@synthesize page = _page;
@synthesize totalPage = _totalPage;
@synthesize topicList = _topicList;
@synthesize forumId = _forumId;
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
@synthesize endOfTopic = _endOfTopic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forumInfo:(NSDictionary *)forumInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.page = 1;
		self.totalPage = 1;
		self.start = 0;
		self.endOfTopic = NO;
		
		self.forumTitle = [forumInfo objectForKey:@"forum_title"];
		NSString *href = [forumInfo objectForKey:@"forum_href"];
		
		self.forumId = [[QueryHelper valueWithURLString:href token:@"f"] integerValue];
		
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
	
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleAll;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.clipsToBounds = NO;
	self.topicTableView = tableView;
	
	[self.view addSubview:self.topicTableView];
	
	UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																					target:self
																					action:@selector(clickRefresh:)] autorelease];
	self.refreshButton = refreshButton;
	
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
	
	UIBarButtonItem *prevButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:kOSXDevBarButtonSystemItemPrev
																				 target:self 
																				 action:@selector(clickPrevious:)] autorelease];
	prevButton.enabled = NO;
	self.prevButton = prevButton;
	
	UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:kOSXDevBarButtonSystemItemNext
																				 target:self 
																				 action:@selector(clickNext:)] autorelease];
	nextButton.enabled = NO;
	self.nextButton = nextButton;
	
	UIBarButtonItem *gotoButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
																				 target:self 
																				 action:@selector(clickGoto:)] autorelease];
	gotoButton.enabled = NO;
	self.gotoButton = gotoButton;
	
	UIBarButtonItem *writeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
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
	
	if (self.forumId != -1) {
		[self.indicatorView startAnimating];
		[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
		
		self.connectionIdentifier = [self.networkObject topicListWithForumId:self.forumId start:self.start];
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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.topicTableView.frame = self.view.bounds;
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
//	self.topicTableView.frame = self.view.bounds;
}

- (void)dealloc
{
    self.networkObject.delegate = nil;
	[self.networkObject closeAllConnections];
	
	[_topicTableView release];
	[_networkObject release];
	[_forumTitle release];
	[_topicList release];
	[_connectionIdentifier release];
	[_indicatorItem release];
	[_prevButton release];
	[_nextButton release];
	[_refreshButton release];
	[_infoLabel release];
	[_gotoButton release];
	[_writeButton release];
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
	self.start -= kOSXDevTopicMaxCount;
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	self.connectionIdentifier = [self.networkObject topicListWithForumId:self.forumId
																   start:self.start];
}

- (void)clickNext:(id)sender {
	if (self.start % kOSXDevTopicMaxCount != 0 || self.endOfTopic) {
		return;
	}
	
	if (self.connectionIdentifier) {
		[self.networkObject closeConnection:self.connectionIdentifier];
	}
	
	self.page += 1;
	self.start += kOSXDevTopicMaxCount;
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	self.connectionIdentifier = [self.networkObject topicListWithForumId:self.forumId
																   start:self.start];
}

- (void)clickRefresh:(id)sender {
	if (self.connectionIdentifier) {
		[self.networkObject closeConnection:self.connectionIdentifier];
	}
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	self.connectionIdentifier = [self.networkObject topicListWithForumId:self.forumId
																   start:self.start];
}

- (void)clickGoto:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"페이지 이동"
														message:@"이동하려는 페이지 번호를 선택하세요.\n\n\n" 
													   delegate:self
											  cancelButtonTitle:@"취소"
											  otherButtonTitles:@"확인", nil];
	alertView.tag = kOSXDevAlertTagMovePage;
	
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
	if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusNotLoggedIn) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 필요"
															message:@"글 작성은 로그인이 필요합니다.\n로그인하시겠습니까?"
														   delegate:self
												  cancelButtonTitle:@"아니오"
												  otherButtonTitles:@"예", nil];
		alertView.tag = kOSXDevAlertTagLoginRequired;
		
		[alertView show];
		[alertView release];
	}
	else {
		PostingViewController *viewController = [[[PostingViewController alloc] initWithNibName:nil
																						 bundle:nil
																						forumId:self.forumId
																						topicId:-1] autorelease];
		viewController.delegate = self;
		
		UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			navController.modalPresentationStyle = UIModalPresentationFormSheet;
		}
		
		[self.navigationController presentModalViewController:navController animated:YES];
	}
}

// MARK: -
// MARK: << UITableView >>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_topicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:cellIdentifier] autorelease];
    }
	
	NSDictionary *topicInfo = [_topicList objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [topicInfo objectForKey:@"topic_title"];
	cell.detailTextLabel.text = [topicInfo objectForKey:@"topic_desc"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *topicInfo = [_topicList objectAtIndex:indexPath.row];
	
	ThreadViewController *viewController = [[[ThreadViewController alloc] initWithNibName:nil 
																				   bundle:nil 
																				topicInfo:topicInfo] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}

// MARK: -
// MARK: << UIAlertViewDelegate >>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex; {
	switch (alertView.tag) {
		case kOSXDevAlertTagError:
		{
			[self clickGoto:nil];
		}
			break;
			
		case kOSXDevAlertTagMovePage:
		{
			if (buttonIndex == 1) {
				// 이동...
				NSInteger page = [[self.pageTextField text] integerValue];
				if (page > self.totalPage || page < 1) {
					UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"페이지 이동 오류"
																			 message:@"페이지를 다시 입력하세요." 
																			delegate:self
																   cancelButtonTitle:nil
																   otherButtonTitles:@"확인", nil];
					alertView.tag = kOSXDevAlertTagError;
					
					[errorAlertView show];
					[errorAlertView release];
				}
				else {
					self.page = page;
					self.start = ((page - 1) * kOSXDevTopicMaxCount);
					
					[self.indicatorView startAnimating];
					[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
					self.connectionIdentifier = [self.networkObject topicListWithForumId:self.forumId
																				   start:self.start];
				}
			}
		}
			break;
			
		case kOSXDevAlertTagLoginRequired:
		{
			if (buttonIndex == 1) {
				LoginViewController *viewController = [[[LoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
				viewController.delegate = self;
				
				UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
				
				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
					navController.modalPresentationStyle = UIModalPresentationFormSheet;
				}
				
				[self.navigationController presentModalViewController:navController animated:YES];
			}
		}
			break;
			
		default:
			break;
	}
}

// MARK: -
// MARK: << PostingViewControllerDelegate >>
- (void)postingViewControllerDidFinishPosting:(PostingViewController *)controller {
	[controller.navigationController dismissModalViewControllerAnimated:YES];
	
	// 글 다시 불러오기.
	[self clickRefresh:nil];
}

// MARK: -
// MARK: << LoginViewControllerDelegate >>
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)controller {
	PostingViewController *viewController = [[[PostingViewController alloc] initWithNibName:nil
																					 bundle:nil
																					forumId:self.forumId
																					topicId:-1] autorelease];
	viewController.delegate = self;
	
	[controller.navigationController pushViewController:viewController animated:YES];
}

- (void)loginViewControllerDidCancel:(LoginViewController *)controller {
	[controller.navigationController dismissModalViewControllerAnimated:YES];
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	[self.navigationItem setRightBarButtonItem:self.refreshButton animated:YES];
	[self.indicatorView stopAnimating];
	
	if ([self.view viewWithTag:kOSXDevErrorLabelTag]) {
		[(UIView *)[self.view viewWithTag:kOSXDevErrorLabelTag] removeFromSuperview];
	}
	
	if (requestType == NetworkRequestViewForum) {
		if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusLoggedIn) {
			NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
			NSRange dataRange = [dataString rangeOfString:@"이 포럼에서 새 글타래를 올릴 수 있습니다."];
			if (dataRange.location != NSNotFound) {
				self.writeButton.enabled = YES;
			}
			else {
				self.writeButton.enabled = NO;
			}
		}
		else {
			// 일단 write button 활성화해야 로그인이 가능하니.
			self.writeButton.enabled = YES;
		}
        
		self.topicList = nil;
		[self.topicTableView reloadData];
		
		NSDictionary *tmpInfo = [HTMLHelper convertTopicInfo:data];
		
		NSArray *topicList = [tmpInfo objectForKey:@"topic_list"];
		self.infoString = [tmpInfo objectForKey:@"topic_info"];
		
		self.topicList = topicList;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.infoLabel.text = self.infoString;
		}
		
		if (self.start < kOSXDevTopicMaxCount) {
			[self.prevButton setEnabled:NO];
		}
		else {
			[self.prevButton setEnabled:YES];
		}
		
		self.endOfTopic = NO;
		
		NSArray *components = [self.infoString componentsSeparatedByString:@"개"];
		self.totalPage = [[components objectAtIndex:1] integerValue];
		[self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %d페이지", self.forumTitle, self.page]];
		
		if ([self.topicList count] < kOSXDevTopicMaxCount) {
			self.endOfTopic = YES;
			[self.nextButton setEnabled:NO];
		}
		else {
			if ([self.topicList count] == kOSXDevTopicMaxCount && self.page == self.totalPage) {
				[self.nextButton setEnabled:NO];
			}
			else {
				[self.nextButton setEnabled:YES];
			}
		}
		
		if ([self.infoString rangeOfString:@"글: 25"].location != NSNotFound) {
			// 일단 한 페이지에 글이 25개 기준으로 25개만 가져오고 25개만 있는 상황일 때...
			[self.prevButton setEnabled:NO];
			[self.nextButton setEnabled:NO];
		}
		
		self.gotoButton.enabled = YES;
		
		[self.topicTableView reloadData]; 
	}
	
	self.connectionIdentifier = nil;
}

- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error {
	[self.navigationItem setRightBarButtonItem:self.refreshButton animated:YES];
	[self.indicatorView stopAnimating];
	
	if (requestType == NetworkRequestViewForum) {
		if ([self.view viewWithTag:kOSXDevErrorLabelTag] == nil) {
			UILabel *errorLabel = [[[UILabel alloc] initWithFrame:self.view.bounds] autorelease];
			errorLabel.autoresizingMask = UIViewAutoresizingFlexibleAll;
			errorLabel.textAlignment = UITextAlignmentCenter;
			errorLabel.backgroundColor = [UIColor whiteColor];
			errorLabel.textColor = [UIColor grayColor];
			errorLabel.font = [UIFont boldSystemFontOfSize:18.f];
			errorLabel.tag = kOSXDevErrorLabelTag;
			errorLabel.numberOfLines = 0;
			errorLabel.text = @"해당 페이지를 불러오지 못하였습니다.\n우측 상단 Refresh 버튼을 눌러서\n재시도를 해주세요.";
			
			[self.view addSubview:errorLabel];
		}
	}
	
	self.connectionIdentifier = nil;
}

@end
