//
//  LoginViewController.h
//  OSXDev
//
//  Created by J.C. Yang on 12. 4. 3..
//  Copyright (c) 2012년 BRID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NetworkObjectDelegate>

@property (assign, nonatomic) id <LoginViewControllerDelegate> delegate;
@property (retain, nonatomic) UITableView *loginTableView;
@property (retain, nonatomic) NetworkObject *networkObject;
@property (retain, nonatomic) NSString *connectionIdentifier;
@property (retain, nonatomic) UITextField *idTextField;
@property (retain, nonatomic) UITextField *pwTextField;
@property (retain, nonatomic) UISwitch *autoLoginSwitch;
@property (retain, nonatomic) UISwitch *viewOnlineSwitch;

@end

@protocol LoginViewControllerDelegate <NSObject>
@required
- (void)loginViewControllerDidFinishLogin:(LoginViewController *)controller;
@optional
- (void)loginViewControllerDidCancel:(LoginViewController *)controller;
@end
