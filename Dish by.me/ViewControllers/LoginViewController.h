//
//  LoginViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@protocol LoginViewControllerDelegate;

@interface LoginViewController : GAITrackedViewController <UITextFieldDelegate>
{
	UIImageView *_forkAndKnife;
	UIImageView *_loginBox;
	UITextField *_emailInput;
	UITextField *_passwordInput;
	UIButton *_loginButton;
	UIButton *_facebookLoginButton;
}

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end


@protocol LoginViewControllerDelegate

- (void)loginViewControllerDidSucceedLogin:(LoginViewController *)loginViewController;

@end