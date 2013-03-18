//
//  SignUpStepTwoViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 18..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface SignUpStepTwoViewController : GAITrackedViewController <UITextFieldDelegate>
{
	NSInteger _userId;
	NSString *_facebookAccessToken;
	
	UIButton *_profilePhotoButton;
	UITextField *_nameInput;
	UITextField *_bioInput;
}

- (id)initWithUserId:(NSInteger)userId;
- (id)initWithUserId:(NSInteger)userId facebookAccessToken:(NSString *)facebookAccessToken;

@end
