//
//  TextFieldViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 17..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMTextFieldViewController.h"
#import "DMBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation DMTextFieldViewController

- (id)init
{
	return [self initWithTitle:nil shouldComplete:nil];
}

- (id)initWithTitle:(NSString *)title shouldComplete:(BOOL (^)(DMTextFieldViewController *textFieldViewController, NSString *text))shouldComplete
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	
	[DMBarButtonItem setBackButtonToViewController:self];
	self.navigationItem.title = title;
	self.navigationItem.rightBarButtonItem = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"SAVE", nil ) target:self action:@selector(saveButtonHandler)];
	
	UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake( 8, (UIScreenHeight - 20 - 44 - 214 - 49)/2, 304, 49 )];
	backgroundView.image = [[UIImage imageNamed:@"cell_grouped.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 8, 8, 8, 8 )];
	backgroundView.userInteractionEnabled = YES;
	[self.view addSubview:backgroundView];
	
	self.textField = [[UITextField alloc] initWithFrame:CGRectMake( 12, 7, 280, 33 )];
	self.textField.delegate = self;
	self.textField.font = [UIFont systemFontOfSize:15];
	self.textField.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
	self.textField.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
	self.textField.layer.shadowOffset = CGSizeMake( 0, 1 );
	self.textField.layer.shadowOpacity = 0.07;
	self.textField.layer.shadowRadius = 1;
	self.textField.borderStyle = UITextBorderStyleNone;
	self.textField.returnKeyType = UIReturnKeyDone;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.textField becomeFirstResponder];
	[backgroundView addSubview:self.textField];
	
	_shouldComplete = shouldComplete;
	
	return self;
}

- (void)saveButtonHandler
{
	if( _shouldComplete && !_shouldComplete( self, self.textField.text ) )
		return;
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
