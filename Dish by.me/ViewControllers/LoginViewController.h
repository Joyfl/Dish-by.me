//
//  LoginViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface LoginViewController : GAITrackedViewController <UITextFieldDelegate>
{
	UIButton *_facebookButton;
	UITextField *_passwordInput;
	UIButton *_loginButton;
	UIButton *_forgotPasswordButton;
}

@property (nonatomic, strong) UITextField *emailInput;

@end