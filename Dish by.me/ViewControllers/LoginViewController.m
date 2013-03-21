//
//  LoginViewController.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CurrentUser.h"
#import "User.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DMAPILoader.h"
#import "UIViewController+Dim.h"
#import "SignUpProfileViewController.h"
#import "HTBlock.h"
#import "AuthViewController.h"
#import "UIButton+TouchAreaInsets.h"

@implementation LoginViewController

- (id)init
{
	self = [super init];
	self.trackedViewName = [self.class description];
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)]];
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	bgView.image = [UIImage imageNamed:@"book_background.png"];
	[self.view addSubview:bgView];
	
	UIImageView *paperView = [[UIImageView alloc] initWithFrame:CGRectMake( 7, 7, 305, 295 )];
	paperView.image = [[UIImage imageNamed:@"book_paper.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 10, 10, 10, 10 )];
	[self.view addSubview:paperView];
	
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake( 30, 35, 9, 15 )];
	backButton.touchAreaInsets = UIEdgeInsetsMake( 15, 15, 15, 15 );
	[backButton setBackgroundImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(backButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = NSLocalizedString( @"LOGIN", nil );
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	titleLabel.textColor = [UIColor colorWithHex:0x4B4A47 alpha:1];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[titleLabel sizeToFit];
	titleLabel.frame = CGRectOffset( titleLabel.frame, 160 - titleLabel.frame.size.width / 2, 30 );
	[self.view addSubview:titleLabel];
	
	DMBookButton *facebookButton = [DMBookButton blueBookButtonWithPosition:CGPointMake( 30, 65 ) title:NSLocalizedString( @"LOGIN_WITH_FACEBOOK", nil )];
	[facebookButton addTarget:self action:@selector(facebookButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:facebookButton];
	
	UILabel *orLabel = [[UILabel alloc] init];
	orLabel.text = NSLocalizedString( @"OR", nil );
	orLabel.font = [UIFont boldSystemFontOfSize:13];
	orLabel.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	orLabel.textAlignment = NSTextAlignmentCenter;
	orLabel.backgroundColor = [UIColor clearColor];
	orLabel.shadowColor = [UIColor whiteColor];
	orLabel.shadowOffset = CGSizeMake( 0, 1 );
	[orLabel sizeToFit];
	orLabel.frame = CGRectOffset( orLabel.frame, 160 - orLabel.frame.size.width / 2, facebookButton.frame.origin.y + facebookButton.frame.size.height + 15 );
	[self.view addSubview:orLabel];
	
	_emailInput = [self inputFieldAtYPosition:150 placeholder:NSLocalizedString( @"EMAIL", nil )];
	_emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	_emailInput.returnKeyType = UIReturnKeyNext;
	[_emailInput addTarget:self action:@selector(inputFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:_emailInput];
	
	_passwordInput = [self inputFieldAtYPosition:_emailInput.frame.origin.y + 40 placeholder:NSLocalizedString( @"PASSWORD", nil )];
	_passwordInput.secureTextEntry = YES;
	_passwordInput.returnKeyType = UIReturnKeyGo;
	[_passwordInput addTarget:self action:@selector(inputFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:_passwordInput];
	
	for( NSInteger i = 0; i < 2; i++ )
	{
		UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 27, 175 + 40 * i, 265, 5 )];
		lineView.image = [UIImage imageNamed:@"book_line.png"];
		[self.view addSubview:lineView];
	}
	
	_loginButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, 247 ) title:NSLocalizedString( @"LOGIN", nil )];
	_loginButton.enabled = NO;
	[_loginButton addTarget:self action:@selector(loginButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_loginButton];
	
	return self;
}

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (UITextField *)inputFieldAtYPosition:(CGFloat)y placeholder:(NSString *)placeholder
{
	UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake( 30, y, 260, 20 )];
	inputField.delegate = self;
	inputField.placeholder = placeholder;
	inputField.font = [UIFont boldSystemFontOfSize:13];
	inputField.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	inputField.backgroundColor = [UIColor clearColor];
	inputField.layer.shadowOffset = CGSizeMake( 0, 1 );
	inputField.layer.shadowColor = [UIColor whiteColor].CGColor;
	inputField.layer.shadowOpacity = 1;
	inputField.layer.shadowRadius = 0;
	inputField.autocorrectionType = UITextAutocorrectionTypeNo;
	inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[inputField addTarget:self action:@selector(inputFieldEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	return inputField;
}

- (void)inputFieldEditingChanged:(UITextField *)inputField
{
	_emailInput.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	
	if( inputField.text.length == 0 )
	{
		[inputField setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	}
	
	_loginButton.enabled = _emailInput.text.length > 0 && _passwordInput.text.length > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if( textField.text.length > 0 )
	{
		if( textField == _emailInput )
		{
			[_passwordInput becomeFirstResponder];
		}
		else if( textField == _passwordInput )
		{
			[self loginButtonDidTouchUpInside];
		}
	}
	
	return NO;
}


#pragma mark -

- (void)backgroundDidTap
{
	[self.view endEditing:YES];
	[UIView animateWithDuration:0.25 animations:^{
		self.view.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height );
	}];
}


- (void)inputFieldEditingDidBegin
{
	[UIView animateWithDuration:0.25 animations:^{
		self.view.frame = CGRectMake( 0, -140, self.view.frame.size.width, self.view.frame.size.height );
	}];
}

- (void)facebookButtonDidTouchUpInside
{
	[self dim];
	
	[FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
		switch( status )
		{
			case FBSessionStateOpen:
			{
				[self loginWithParameters:@{ @"facebook_token": [[FBSession activeSession] accessToken] }];
				break;
			}
				
			case FBSessionStateClosedLoginFailed:
				[self undim];
				JLLog( @"FBSessionStateClosedLoginFailed (User canceled login to facebook)" );
				break;
				
			default:
				[self undim];
				break;
		}
	}];
}

- (void)loginButtonDidTouchUpInside
{
	if( _emailInput.text.length == 0 )
	{
		[_emailInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[_emailInput becomeFirstResponder];
		return;
	}
	
	if( _passwordInput.text.length == 0 )
	{
		[_passwordInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[_passwordInput becomeFirstResponder];
		return;
	}
	
	[self backgroundDidTap];
	[self loginWithParameters:@{ @"email": _emailInput.text, @"password": [Utils sha1:_passwordInput.text] }];
}

- (void)loginWithParameters:(NSDictionary *)parameters
{
	[self dim];
	
	[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:parameters success:^(id response) {
		JLLog( @"Login complete" );
		
		[self undim];
		
		[CurrentUser user].loggedIn = YES;
		[CurrentUser user].accessToken = [response objectForKey:@"access_token"];
		
		[(AuthViewController *)[self.navigationController.viewControllers objectAtIndex:0] getUserAndDismissViewController];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self undim];
		showErrorAlert();
	}];
}

@end
