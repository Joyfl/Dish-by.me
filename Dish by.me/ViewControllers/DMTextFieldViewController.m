//
//  TextFieldViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 17..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMTextFieldViewController.h"
#import "DMBarButtonItem.h"

@implementation DMTextFieldViewController

- (id)init
{
	return [self initWithTitle:nil completion:nil];
}

- (id)initWithTitle:(NSString *)title completion:(void (^)(DMTextFieldViewController *textFieldViewController, NSString *text))completion
{
	self = [super init];
	
	[DMBarButtonItem setBackButtonToViewController:self];
	self.navigationItem.title = title;
	self.navigationItem.rightBarButtonItem = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"SAVE", nil ) target:self action:@selector(saveButtonHandler)];
	
	self.textField = [[UITextField alloc] initWithFrame:CGRectMake( 10, 10, 300, 30 )];
	self.textField.delegate = self;
	self.textField.borderStyle = UITextBorderStyleRoundedRect;
	self.textField.returnKeyType = UIReturnKeyDone;
	[self.textField becomeFirstResponder];
	[self.view addSubview:self.textField];
	
	_completion = completion;
	
	return self;
}

- (void)saveButtonHandler
{
	if( _completion ) _completion( self, self.textField.text );
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self saveButtonHandler];
	return YES;
}

@end
