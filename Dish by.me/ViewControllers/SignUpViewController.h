//
//  SignUpViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "DMBookButton.h"

@interface SignUpViewController : GAITrackedViewController <UITextFieldDelegate>
{
	UITextField *_emailInput;
	UITextField *_passwordInput;
	UITextField *_passwordConfirmationInput;
	DMBookButton *_signUpButton;
	DMBookButton *_facebookButton;
}

@end
