//
//  SettingViewController.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 30..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UILabel *tmpLabel = [[[UILabel alloc] initWithFrame:self.view.bounds] autorelease];
	tmpLabel.autoresizingMask = UIViewAutoresizingFlexibleAll;
	tmpLabel.textAlignment = UITextAlignmentCenter;
	tmpLabel.backgroundColor = [UIColor whiteColor];
	tmpLabel.textColor = [UIColor darkGrayColor];
	tmpLabel.font = [UIFont boldSystemFontOfSize:18.f];
	tmpLabel.numberOfLines = 0;
	tmpLabel.text = [NSString stringWithFormat:@"%Version : %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	
	[self.view addSubview:tmpLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

@end
