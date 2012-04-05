//
//  BrowserViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 30..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()
- (void)clickPrevious:(id)sender;
- (void)clickNext:(id)sender;
- (void)clickRefresh:(id)sender;
- (void)clickStop:(id)sender;
- (void)clickExternalLink:(id)sender;
@end

@implementation BrowserViewController

@synthesize browserWebView = _browserWebView;
@synthesize indicatorView = _indicatorView;
@synthesize indicatorItem = _indicatorItem;
@synthesize prevPageItem = _prevPageItem;
@synthesize nextPageItem = _nextPageItem;
@synthesize refreshPageItem = _refreshPageItem;
@synthesize stopPageItem = _stopPageItem;
@synthesize externalLinkItem = _externalLinkItem;
@synthesize blankSpace = _blankSpace;
@synthesize requestURL = _requestURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.requestURL = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor clearColor];
	
	[self.navigationItem setTitle:[self.requestURL absoluteString]];
	
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
	
	[self.navigationItem setRightBarButtonItem:indicatorItem animated:YES];
	
	UIBarButtonItem *prevPageItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:kOSXDevBarButtonSystemItemPrev
																				   target:self
																				   action:@selector(clickPrevious:)] autorelease];
	prevPageItem.enabled = NO;
	self.prevPageItem = prevPageItem;
	
	UIBarButtonItem *nextPageItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:kOSXDevBarButtonSystemItemNext
																				   target:self
																				   action:@selector(clickNext:)] autorelease];
	nextPageItem.enabled = NO;
	self.nextPageItem = nextPageItem;
	
	UIBarButtonItem *stopPageItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																				   target:self
																				   action:@selector(clickStop:)] autorelease];
	self.stopPageItem = stopPageItem;
	
	UIBarButtonItem *refreshPageItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																					  target:self
																					  action:@selector(clickRefresh:)] autorelease];
	self.refreshPageItem = refreshPageItem;
	
	UIBarButtonItem *externalLinkItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																					   target:self
																					   action:@selector(clickExternalLink:)] autorelease];
	self.externalLinkItem = externalLinkItem;
	
	UIBarButtonItem *blankSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
								   autorelease];
	self.blankSpace = blankSpace;
	
	NSArray *items = [NSArray arrayWithObjects:prevPageItem, blankSpace, nextPageItem, blankSpace, stopPageItem, blankSpace, externalLinkItem, nil];
	[self setToolbarItems:items animated:YES];
	
	UIWebView *webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
	webView.autoresizingMask = UIViewAutoresizingFlexibleAll;
	webView.dataDetectorTypes = UIDataDetectorTypeAll;
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	self.browserWebView = webView;
	
	[self.view addSubview:self.browserWebView];
	
	[self.indicatorView startAnimating];
	[self.browserWebView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
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
		[self.browserWebView stringByEvaluatingJavaScriptFromString:@"rotate(0)"];	
	}
	else{
		[self.browserWebView stringByEvaluatingJavaScriptFromString:@"rotate(1)"];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.browserWebView.frame = self.view.bounds;
}

- (void)dealloc
{
	self.browserWebView.delegate = nil;
    [_browserWebView release];
	
	[_indicatorView release];
	[_indicatorItem release];
	[_prevPageItem release];
	[_nextPageItem release];
	[_refreshPageItem release];
	[_stopPageItem release];
	[_externalLinkItem release];
	[_blankSpace release];
	[_requestURL release];
	
    [super dealloc];
}

// MARK: -
// MARK: << Private methods >>
- (void)clickPrevious:(id)sender {
	[self.browserWebView goBack];
}

- (void)clickNext:(id)sender {
	[self.browserWebView goForward];
}

- (void)clickRefresh:(id)sender {
	[self.browserWebView reload];
}

- (void)clickStop:(id)sender {
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	[self.indicatorView stopAnimating];
	
	[self.browserWebView stopLoading];
	
	NSArray *items = [NSArray arrayWithObjects:self.prevPageItem, self.blankSpace, self.nextPageItem, self.blankSpace, self.refreshPageItem, self.blankSpace, self.externalLinkItem, nil];
	[self setToolbarItems:items animated:YES];
}

- (void)clickExternalLink:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"취소" 
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Open In Safari", nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
	[actionSheet release];
}

// MARK: -
// MARK: << UIWebViewDelegate >>
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self.indicatorView startAnimating];
	[self.navigationItem setRightBarButtonItem:self.indicatorItem animated:YES];
	
	NSArray *items = [NSArray arrayWithObjects:self.prevPageItem, self.blankSpace, self.nextPageItem, self.blankSpace, self.stopPageItem, self.blankSpace, self.externalLinkItem, nil];
	[self setToolbarItems:items animated:YES];
	
	if (self.browserWebView.canGoBack) {
		[self.prevPageItem setEnabled:YES];
	}
	else {
		[self.prevPageItem setEnabled:NO];
	}
	
	if (self.browserWebView.canGoForward) {
		[self.nextPageItem setEnabled:YES];
	}
	else {
		[self.nextPageItem setEnabled:NO];
	}
	
	[self.navigationItem setTitle:[webView.request.URL absoluteString]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	[self.indicatorView stopAnimating];
	
	NSArray *items = [NSArray arrayWithObjects:self.prevPageItem, self.blankSpace, self.nextPageItem, self.blankSpace, self.refreshPageItem, self.blankSpace, self.externalLinkItem, nil];
	[self setToolbarItems:items animated:YES];
	
	if (self.browserWebView.canGoBack) {
		[self.prevPageItem setEnabled:YES];
	}
	else {
		[self.prevPageItem setEnabled:NO];
	}
	
	if (self.browserWebView.canGoForward) {
		[self.nextPageItem setEnabled:YES];
	}
	else {
		[self.nextPageItem setEnabled:NO];
	}
	
	NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self.navigationItem setTitle:pageTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	[self.indicatorView stopAnimating];
	
	NSArray *items = [NSArray arrayWithObjects:self.prevPageItem, self.blankSpace, self.nextPageItem, self.blankSpace, self.refreshPageItem, self.blankSpace, self.externalLinkItem, nil];
	[self setToolbarItems:items animated:YES];
	
	if (self.browserWebView.canGoBack) {
		[self.prevPageItem setEnabled:YES];
	}
	else {
		[self.prevPageItem setEnabled:NO];
	}
	
	if (self.browserWebView.canGoForward) {
		[self.nextPageItem setEnabled:YES];
	}
	else {
		[self.nextPageItem setEnabled:NO];
	}
}

// MARK: -
// MARK: << UIActionSheetDelegate >>
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[[UIApplication sharedApplication] openURL:self.browserWebView.request.URL];
	}
}

@end
