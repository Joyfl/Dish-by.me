//
//  TextFieldViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 17..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface DMTextFieldViewController : GAITrackedViewController <UITextFieldDelegate>
{
	BOOL (^_shouldComplete)(DMTextFieldViewController *textFieldViewController, NSString *text);
}

@property (nonatomic, strong) UITextField *textField;

- (id)initWithTitle:(NSString *)title shouldComplete:(BOOL (^)(DMTextFieldViewController *textFieldViewController, NSString *text))completion;

@end