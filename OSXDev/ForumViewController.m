//
//  ForumViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "ForumViewController.h"

#import "TopicViewController.h"
#import "ThreadViewController.h"
#import "SettingViewController.h"

#define kOSXDevConnectionInfoKeyReqForum		@"req_forum"
#define kOSXDevConnectionInfoKeyReqLogin		@"req_login"

@interface ForumViewController ()
- (void)clickRefresh:(id)sender;
//- (void)clickSetting:(id)sender;
- (void)clickLogin:(id)sender;
- (void)clickLogout:(id)sender;
@end

@implementation ForumViewController

@synthesize forumTableView = _forumTableView;
@synthesize networkObject = _networkObject;
@synthesize forumList = _forumList;
@synthesize activeTopicList = _activeTopicList;
@synthesize sectionHeaderList = _sectionHeaderList;
//@synthesize connectionIdentifier = _connectionIdentifier;
@synthesize connectionInfo = _connectionInfo;
@synthesize indicatorView = _indicatorView;
@synthesize indicatorItem = _indicatorItem;
@synthesize refreshButton = _refreshButton;
@synthesize targetPopoverController = _targetPopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.navigationController.view.backgroundColor = [UIColor whiteColor];
	self.view.backgroundColor = [UIColor clearColor];
	
	[self.navigationItem setTitle:@"OSXDev"];
	
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
	
	NetworkObject *networkObject = [[[NetworkObject alloc] initWithDelegate:self] autorelease];
	self.networkObject = networkObject;
	
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleAll;
	tableView.delegate = self;
	tableView.dataSource = self;
	self.forumTableView = tableView;
	
	[self.view addSubview:self.forumTableView];
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	NSMutableDictionary *connectionInfo = [NSMutableDictionary dictionaryWithCapacity:0];
	self.connectionInfo = connectionInfo;
	
	// TODO :
	// 쿠키 정리 후에 앱 입장할 때 자동로그인 설정되어 있으면 로그인 시도한다.
	// [UserInfo sharedInfo].autoLogin
	NSString *connectionIdentifier = nil;
	if ([[UserInfo sharedInfo] userId] != nil && [[UserInfo sharedInfo] userPassword] != nil &&
		[UserInfo sharedInfo].autoLogin) {
		[SVProgressHUD showInView:self.view status:@"로그인중..."];
		
		connectionIdentifier = [self.networkObject login];
		[self.connectionInfo setObject:connectionIdentifier forKey:kOSXDevConnectionInfoKeyReqLogin];
	}
	else {
		UIBarButtonItem *loginButton = [[[UIBarButtonItem alloc] initWithTitle:@"로그인"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(clickLogin:)] autorelease];
		[self.navigationItem setLeftBarButtonItem:loginButton animated:NO];
		
		[SVProgressHUD showInView:self.view status:@"목록 불러오는 중..."];
		
		connectionIdentifier = [self.networkObject forumList];
		[self.connectionInfo setObject:connectionIdentifier forKey:kOSXDevConnectionInfoKeyReqForum];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	UIBarButtonItem *item = nil;
	if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusLoggedIn) {
		item = [[[UIBarButtonItem alloc] initWithTitle:@"로그아웃"
												 style:UIBarButtonItemStylePlain
												target:self
												action:@selector(clickLogout:)] autorelease];
	}
	else {
		item = [[[UIBarButtonItem alloc] initWithTitle:@"로그인"
												 style:UIBarButtonItemStylePlain
												target:self
												action:@selector(clickLogin:)] autorelease];
	}
	
	[self.navigationItem setLeftBarButtonItem:item animated:NO];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//	self.forumTableView.frame = self.view.bounds;
}

- (void)dealloc
{
	self.networkObject.delegate = nil;
	[self.networkObject closeAllConnections];
	
	[_networkObject release];
	[_forumList release];
	[_activeTopicList release];
	[_sectionHeaderList release];
    [_forumTableView release];
//	[_connectionIdentifier release];
	[_connectionInfo release];
	[_indicatorView release];
	[_indicatorItem release];
	[_refreshButton release];
	[_targetPopoverController release];
	
    [super dealloc];
}

// MARK: -
// MARK: << Private methods >>
- (void)clickRefresh:(id)sender {
	if ([self.connectionInfo objectForKey:kOSXDevConnectionInfoKeyReqForum]) {
		[self.networkObject closeConnection:[self.connectionInfo objectForKey:kOSXDevConnectionInfoKeyReqForum]];
		[self.connectionInfo removeObjectForKey:kOSXDevConnectionInfoKeyReqForum];
	}
	
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	NSString *connectionIdentifier = [self.networkObject forumList];
	[self.connectionInfo setObject:connectionIdentifier forKey:kOSXDevConnectionInfoKeyReqForum];
}

/*
- (void)clickSetting:(id)sender {
	SettingViewController *viewController = [[[SettingViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else {
		if (self.targetPopoverController == nil) {
			UIPopoverController *tmpPopoverController = [[[UIPopoverController alloc] initWithContentViewController:viewController] autorelease];
			tmpPopoverController.delegate = self;
			tmpPopoverController.popoverContentSize = CGSizeMake(320.f, 460.f);
			self.targetPopoverController = tmpPopoverController;
		}
		
		[self.targetPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem
											 permittedArrowDirections:UIPopoverArrowDirectionUp
															 animated:YES];
	}
}
 */

- (void)clickLogin:(id)sender {
	LoginViewController *viewController = [[[LoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	viewController.delegate = self;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		navController.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	[self.navigationController presentModalViewController:navController animated:YES];
}

- (void)clickLogout:(id)sender {
	[[UserInfo sharedInfo] logout];
	
	UIBarButtonItem *loginButton = [[[UIBarButtonItem alloc] initWithTitle:@"로그인"
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(clickLogin:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:loginButton animated:NO];
}

// MARK: -
// MARK: << UIPopoverControllerDelegate >>
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.targetPopoverController = nil;
}

// MARK: -
// MARK: << UITableView >>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sectionHeaderList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = 0;;
	
	switch (section) {
		case 0:
			rowCount = [self.forumList count];
			break;
			
		case 1:
			rowCount = [self.activeTopicList count];
			break;
			
		default:
			break;
	}
	
	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:cellIdentifier] autorelease];
    }
	
	switch (indexPath.section) {
		case 0:
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			NSDictionary *forumInfo = [self.forumList objectAtIndex:indexPath.row];
			NSString *title = [forumInfo objectForKey:@"forum_title"];
			NSString *desc = [forumInfo objectForKey:@"forum_desc"];
			
			cell.textLabel.text = title;
			cell.detailTextLabel.text = desc;
		}
			break;
			
		case 1:
		{
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			NSDictionary *topicInfo = [self.activeTopicList objectAtIndex:indexPath.row];
			cell.textLabel.text = [topicInfo objectForKey:@"topic_title"];
			cell.detailTextLabel.text = [topicInfo objectForKey:@"topic_desc"];
		}
			break;
			
		default:
			break;
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.sectionHeaderList objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
		case 0:
		{
			NSDictionary *forumInfo = [self.forumList objectAtIndex:indexPath.row];
			TopicViewController *viewController = [[[TopicViewController alloc] initWithNibName:nil 
																						 bundle:nil 
																					  forumInfo:forumInfo] autorelease];
			[self.navigationController pushViewController:viewController animated:YES];
		}
			break;
			
		case 1:
		{
			NSDictionary *topicInfo = [self.activeTopicList objectAtIndex:indexPath.row];
			
			ThreadViewController *viewController = [[[ThreadViewController alloc] initWithNibName:nil 
																						   bundle:nil 
																						topicInfo:topicInfo] autorelease];
			[self.navigationController pushViewController:viewController animated:YES];
		}
			break;
			
		default:
			break;
	}
}

// MARK: -
// MARK: << LoginViewControllerDelegate >>
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)controller {
	[controller dismissModalViewControllerAnimated:YES];
	
	UIBarButtonItem *item = nil;
	if ([UserInfo sharedInfo].loginStatus == UserInfoLoginStatusLoggedIn) {
		item = [[[UIBarButtonItem alloc] initWithTitle:@"로그아웃"
												 style:UIBarButtonItemStylePlain
												target:self
												action:@selector(clickLogout:)] autorelease];
	}
	else {
		item = [[[UIBarButtonItem alloc] initWithTitle:@"로그인"
												 style:UIBarButtonItemStylePlain
												target:self
												action:@selector(clickLogin:)] autorelease];
	}
	
	[self.navigationItem setLeftBarButtonItem:item animated:NO];
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	[SVProgressHUD dismiss];
	
	[self.navigationItem setRightBarButtonItem:self.refreshButton animated:YES];
	[self.indicatorView stopAnimating];
	
	if ([self.view viewWithTag:kOSXDevErrorLabelTag]) {
		[(UIView *)[self.view viewWithTag:kOSXDevErrorLabelTag] removeFromSuperview];
	}
	
	if (requestType == NetworkRequestForumList) {
		NSDictionary *forumInfo = [HTMLHelper convertForumInfo:data];
		
		NSArray *tmpList = [forumInfo objectForKey:@"forum_list"];
		self.forumList = tmpList;
		
		NSArray *tmpTopicList = [forumInfo objectForKey:@"topic_list"];
		self.activeTopicList = tmpTopicList;
		
		NSArray *sectionHeaderList = [forumInfo objectForKey:@"topic_header"];
		self.sectionHeaderList = sectionHeaderList;

		[self.forumTableView reloadData];
		
		if ([self.connectionInfo objectForKey:kOSXDevConnectionInfoKeyReqForum]) {
			[self.connectionInfo removeObjectForKey:kOSXDevConnectionInfoKeyReqForum];
		}
	}
	else if (requestType == NetworkRequestLogin) {
		if ([HTMLHelper isValidData:data requestType:requestType] == NO) {
			[[UserInfo sharedInfo] logout];
			[[UserInfo sharedInfo] setLoginStatus:UserInfoLoginStatusNotLoggedIn];
			
			// login 오류.
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 오류"
																message:@"로그인에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
															   delegate:self
													  cancelButtonTitle:@"확인"
													  otherButtonTitles:nil, nil];
			
			[alertView show];
			[alertView release];
		}
		else {
			UIBarButtonItem *logoutButton = [[[UIBarButtonItem alloc] initWithTitle:@"로그아웃"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(clickLogout:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:logoutButton animated:NO];
			
			[[UserInfo sharedInfo] setLoginStatus:UserInfoLoginStatusLoggedIn];
		}
		
		if ([self.connectionInfo objectForKey:kOSXDevConnectionInfoKeyReqLogin]) {
			[self.connectionInfo removeObjectForKey:kOSXDevConnectionInfoKeyReqLogin];
		}
		
		[SVProgressHUD showInView:self.view status:@"목록 불러오는 중..."];
		
		[self.indicatorView startAnimating];
		[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
		
		NSString *connectionIdentifier = [self.networkObject forumList];
		[self.connectionInfo setObject:connectionIdentifier forKey:kOSXDevConnectionInfoKeyReqForum];
	}
	else {
		
	}
}

- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error {
	[SVProgressHUD dismiss];
	
	[self.navigationItem setRightBarButtonItem:self.refreshButton animated:YES];
	[self.indicatorView stopAnimating];
	
	if (requestType == NetworkRequestForumList) {
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
		
		if ([self.connectionInfo objectForKey:kOSXDevConnectionInfoKeyReqForum]) {
			[self.connectionInfo removeObjectForKey:kOSXDevConnectionInfoKeyReqForum];
		}
	}
	else if (requestType == NetworkRequestLogin) {
		[[UserInfo sharedInfo] logout];
		[[UserInfo sharedInfo] setLoginStatus:UserInfoLoginStatusNotLoggedIn];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 오류"
															message:@"로그인에 실패하였습니다.\n좌측 상단 로그인 버튼으로\n재시도 해주세요." 
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		
		[alertView show];
		[alertView release];
		
		if ([self.connectionInfo objectForKey:kOSXDevConnectionInfoKeyReqLogin]) {
			[self.connectionInfo removeObjectForKey:kOSXDevConnectionInfoKeyReqLogin];
		}
		
		[SVProgressHUD showInView:self.view status:@"목록 불러오는 중..."];
		
		[self.indicatorView startAnimating];
		[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
		
		NSString *connectionIdentifier = [self.networkObject forumList];
		[self.connectionInfo setObject:connectionIdentifier forKey:kOSXDevConnectionInfoKeyReqForum];
	}
	else {
		
	}
}

@end
