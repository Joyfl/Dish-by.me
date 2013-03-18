//
//  SignUpViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 18..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface SignUpStepOneViewController : GAITrackedViewController <UITextFieldDelegate>
{
	UITextField *_emailInput;
	UITextField *_passwordInput;
	
	BOOL _isLastErrorAlreadySignedUp;
}

@end
