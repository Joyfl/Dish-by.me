//
//  LoginViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLHTTPLoader.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, JLHTTPLoaderDelegate>
{
	UIImageView *_forkAndKnife;
	UIImageView *_loginBox;
	UITextField *_emailInput;
	UITextField *_passwordInput;
	UIButton *_loginButton;
	UIButton *_facebookLoginButton;
	
	JLHTTPLoader *_loader;
	
	id target;
	SEL action;
}

- (id)initWithTarget:(id)target action:(SEL)action;

@end
