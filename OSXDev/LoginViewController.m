//
//  LoginViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 BRID. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
- (void)clickCancel:(id)sender;
- (void)startLoginRequest;
- (void)autoLoginValueChanged:(id)sender;
- (void)viewOnlineValueChanged:(id)sender;
@end

@implementation LoginViewController

@synthesize delegate = _delegate;
@synthesize loginTableView = _loginTableView;
@synthesize networkObject = _networkObject;
@synthesize connectionIdentifier = _connectionIdentifier;
@synthesize idTextField = _idTextField;
@synthesize pwTextField = _pwTextField;
@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize viewOnlineSwitch = _viewOnlineSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		[self.navigationItem setTitle:@"로그인"];
		
		NetworkObject *networkObject = [[[NetworkObject alloc] initWithDelegate:self] autorelease];
		self.networkObject = networkObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				   target:self
																				   action:@selector(clickCancel:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
	
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleAll;
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.allowsSelection = NO;
	
	self.loginTableView = tableView;
	
	[self.view addSubview:self.loginTableView];
	
	[self.loginTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.idTextField) {
		[self.idTextField becomeFirstResponder];
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
	[_loginTableView release];
	[_connectionIdentifier release];
	[_idTextField release];
	[_pwTextField release];
	[_autoLoginSwitch release];
	[_viewOnlineSwitch release];
	
    [super dealloc];
}

// MARK: -
// MARK: << Private methods >>
- (void)clickCancel:(id)sender {
	[[UserInfo sharedInfo] setUserId:nil];
	[[UserInfo sharedInfo] setUserPassword:nil];
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)startLoginRequest {
	NSLog(@"startLoginRequest called");
	
	if (self.idTextField.text) {
		[[UserInfo sharedInfo] setUserId:self.idTextField.text];
	}
	
	if (self.pwTextField.text) {
		[[UserInfo sharedInfo] setUserPassword:self.pwTextField.text];
	}
	
	[SVProgressHUD showInView:self.view status:@"로그인 중..."];
	self.connectionIdentifier = [self.networkObject login];
}

- (void)autoLoginValueChanged:(id)sender {
	BOOL on = ((UISwitch *)sender).isOn;
	[[UserInfo sharedInfo] setAutoLogin:on];
}

- (void)viewOnlineValueChanged:(id)sender {
	BOOL on = ((UISwitch *)sender).isOn;
	[[UserInfo sharedInfo] setViewOnline:on];
}

// MARK: -
// MARK: << UITableView >>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 40.f;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		height = 50.f;
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
	
	switch (indexPath.row) {
		case 0:
		{
			cell.textLabel.text = @"아이디";
			
			if (self.idTextField == nil) {
				CGRect textFieldRect = cell.bounds;
				textFieldRect.origin.x = 0.f;
				textFieldRect.origin.y = 0.f;
				
				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
					textFieldRect.size.width = self.loginTableView.bounds.size.width - 110.f;
				}
				else {
					textFieldRect.size.width = self.loginTableView.bounds.size.width - 160.f;
				}
				
				textFieldRect.size.height = 20.f;
				
				UITextField *textField = [[[UITextField alloc] initWithFrame:textFieldRect] autorelease];
				textField.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
				textField.textColor = [UIColor darkGrayColor];
				textField.textAlignment = UITextAlignmentRight;
				textField.delegate = self;
				
				textField.placeholder = @"아이디를 입력하세요.";
				textField.returnKeyType = UIReturnKeyNext;
				
				self.idTextField = textField;
			}
			
			cell.accessoryView = self.idTextField;
		}
			break;
			
		case 1:
		{
			cell.textLabel.text = @"패스워드";
			
			if (self.pwTextField == nil) {
				CGRect textFieldRect = cell.bounds;
				textFieldRect.origin.x = 0.f;
				textFieldRect.origin.y = 0.f;
				
				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
					textFieldRect.size.width = self.loginTableView.bounds.size.width - 120.f;
				}
				else {
					textFieldRect.size.width = self.loginTableView.bounds.size.width - 170.f;
				}
				
				textFieldRect.size.height = 20.f;
				
				UITextField *textField = [[[UITextField alloc] initWithFrame:textFieldRect] autorelease];
				textField.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
				textField.textColor = [UIColor darkGrayColor];
				textField.textAlignment = UITextAlignmentRight;
				textField.delegate = self;
				
				textField.placeholder = @"패스워드를 입력하세요.";
				textField.returnKeyType = UIReturnKeyDone;
				textField.secureTextEntry = YES;
				
				self.pwTextField = textField;
			}
			
			cell.accessoryView = self.pwTextField;
		}
			break;
			
		case 2:
		{
			cell.textLabel.text = @"자동 로그인";
			
			if (self.autoLoginSwitch == nil) {
				UISwitch *tmpSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
				[tmpSwitch addTarget:self action:@selector(autoLoginValueChanged:) forControlEvents:UIControlEventValueChanged];
				tmpSwitch.on = [UserInfo sharedInfo].autoLogin;
				
				self.autoLoginSwitch = tmpSwitch;
			}
			
			cell.accessoryView = self.autoLoginSwitch;
		}
			break;
			
		case 3:
		{
			cell.textLabel.text = @"접속 상태 비공개";
			
			if (self.viewOnlineSwitch == nil) {
				UISwitch *tmpSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
				[tmpSwitch addTarget:self action:@selector(viewOnlineValueChanged:) forControlEvents:UIControlEventValueChanged];
				tmpSwitch.on = [UserInfo sharedInfo].viewOnline;
				
				self.viewOnlineSwitch = tmpSwitch;
			}
			
			cell.accessoryView = self.viewOnlineSwitch;
		}
			break;
			
		default:
			break;
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"아이디와 비밀번호는 암호화 되어 저장됩니다.";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.loginTableView) {
		[self.idTextField resignFirstResponder];
		[self.pwTextField resignFirstResponder];
	}
}

// MARK: -
// MARK: << UITextFieldDelegate >>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.idTextField) {
		[self.pwTextField becomeFirstResponder];
	}
	else if (textField == self.pwTextField) {
		[self startLoginRequest];
	}
	else {
		
	}
	
	return YES;
}

// MARK: -
// MARK: << NetworkObjectDelegate >>
- (void)requestSucceed:(NSData *)data forRequest:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType {
	[SVProgressHUD dismiss];
	
	if (requestType == NetworkRequestLogin) {
		[[UserInfo sharedInfo] setLoginStatus:UserInfoLoginStatusLoggedIn];
		
		if (self.delegate) {
			[self.delegate loginViewControllerDidFinishLogin:self];
		}
	}
	
	self.connectionIdentifier = nil;
}

- (void)requestFailed:(NSString *)connectionIdentifier requestType:(NetworkRequestType)requestType error:(NSError *)error {
	if (requestType == NetworkRequestLogin) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 오류"
															message:@"로그인에 실패하였습니다.\n잠시 후에 다시 시도해주세요." 
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil, nil];
		
		[alertView show];
		[alertView release];
	}
	
	self.connectionIdentifier = nil;
}

@end
