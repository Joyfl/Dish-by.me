//
//  ForgotPasswordViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 28..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface ForgotPasswordViewController : GAITrackedViewController <UITextFieldDelegate>
{
	UIButton *_sendEmailButton;
}

@property (nonatomic, strong) UITextField *emailInput;

@end
