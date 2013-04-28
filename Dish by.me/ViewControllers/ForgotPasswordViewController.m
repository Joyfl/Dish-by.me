//
//  ForgotPasswordViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 28..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "DMBarButtonItem.h"
#import "UIButton+TouchAreaInsets.h"
#import <QuartzCore/QuartzCore.h>
#import "DMBookButton.h"

@implementation ForgotPasswordViewController

- (id)init
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	bgView.image = [UIImage imageNamed:@"book_background.png"];
	[self.view addSubview:bgView];
	
	UIImageView *paperView = [[UIImageView alloc] initWithFrame:CGRectMake( 7, 7, 305, 230 )];
	paperView.image = [[UIImage imageNamed:@"book_paper.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 10, 10, 10, 10 )];
	[self.view addSubview:paperView];
	
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake( 28, 33, 12, 18 )];
	backButton.touchAreaInsets = UIEdgeInsetsMake( 15, 15, 15, 15 );
	[backButton setBackgroundImage:[UIImage imageNamed:@"book_button_back.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(backButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = NSLocalizedString( @"RESET_PASSWORD", nil );
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	titleLabel.textColor = [UIColor colorWithHex:0x4B4A47 alpha:1];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[titleLabel sizeToFit];
	titleLabel.frame = CGRectOffset( titleLabel.frame, 160 - titleLabel.frame.size.width / 2, 30 );
	[self.view addSubview:titleLabel];
	
	self.emailInput = [[UITextField alloc] initWithFrame:CGRectMake( 30, 80, 260, 20 )];
	self.emailInput.delegate = self;
	self.emailInput.placeholder = NSLocalizedString( @"SIGNED_UP_EMAIL", nil );
	self.emailInput.font = [UIFont boldSystemFontOfSize:13];
	self.emailInput.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
	[self.emailInput setValue:[UIColor colorWithHex:0xADA8A3 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	self.emailInput.backgroundColor = [UIColor clearColor];
	self.emailInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	self.emailInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	self.emailInput.layer.shadowOpacity = 1;
	self.emailInput.layer.shadowRadius = 0;
	self.emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailInput.returnKeyType = UIReturnKeyGo;
	[self.emailInput becomeFirstResponder];
	[self.emailInput addTarget:self action:@selector(emailInputEditingChanged) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:self.emailInput];
	
	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 27, self.emailInput.frame.origin.y + 25, 265, 5 )];
	lineView.image = [UIImage imageNamed:@"book_line.png"];
	[self.view addSubview:lineView];
	
	_sendEmailButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, self.emailInput.frame.origin.y + 57 ) title:NSLocalizedString( @"SEND_EMAIL", nil )];
	_sendEmailButton.enabled = NO;
	[_sendEmailButton addTarget:self action:@selector(sendEmailButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_sendEmailButton];
	
	return self;
}

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)emailInputEditingChanged
{
	_sendEmailButton.enabled = self.emailInput.text.length > 0;
}


#pragma mark -

- (void)sendEmailButtonDidTouchUpInside
{
	[[DMAPILoader sharedLoader] api:@"/auth/password" method:@"POST" parameters:@{ @"email": _emailInput.text } success:^(id response) {
		
		JLLog( @"메일 전송됨" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
		showErrorAlert();
	}];
}

@end
