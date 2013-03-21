//
//  SignUpStepTwoViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 18..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "DMBookButton.h"

@interface SignUpProfileViewController : GAITrackedViewController <UITextFieldDelegate>
{
	NSInteger _userId;
	NSString *_facebookAccessToken;
	
	UIButton *_userPhotoButton;
	UITextField *_nameInput;
	UITextField *_bioInput;
	
	DMBookButton *_doneButton;
}

- (id)initWithUserId:(NSInteger)userId;
- (id)initWithUserId:(NSInteger)userId facebookAccessToken:(NSString *)facebookAccessToken;

@end
