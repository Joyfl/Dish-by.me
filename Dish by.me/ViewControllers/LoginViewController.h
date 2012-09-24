//
//  LoginViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APILoader.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, APILoaderDelegate>
{
	UIImageView *forkAndKnife;
	UIImageView *loginBox;
	UITextField *emailInput;
	UITextField *passwordInput;
	UIButton *loginButton;
	UIButton *facebookLoginButton;
	
	APILoader *loader;
	
	id target;
	SEL action;
}

- (id)initWithTarget:(id)target action:(SEL)action;

@end
