//
//  LoginViewController.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "LoginViewController.h"
#import "DMBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "CurrentUser.h"
#import "User.h"
#import "JLHTTPLoader.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DMAPILoader.h"
#import "UIViewController+Dim.h"
#import "SignUpStepOneViewController.h"
#import "SignUpStepTwoViewController.h"
#import "HTBlock.h"

@implementation LoginViewController

- (id)init
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	DMBarButtonItem *cancelButton = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	UIButton *bgView = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	bgView.adjustsImageWhenHighlighted = NO;
	if( UIScreenHeight < 568 )
		[bgView setBackgroundImage:[UIImage imageNamed:@"login_bg.png"] forState:UIControlStateNormal];
	else
		[bgView setBackgroundImage:[UIImage imageNamed:@"login_bg-568h.png"] forState:UIControlStateNormal];
	[bgView addTarget:self action:@selector(bgViewDidTouchDown) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:bgView];
	
	UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake( 280, 15, 26, 26 )];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"login_close_button.png"] forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(closeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:closeButton];
	
	_forkAndKnife = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fork_knife.png"]];
	_forkAndKnife.frame = CGRectMake( 140, 55, 80, 90 );
	[self.view addSubview:_forkAndKnife];
	
	_loginBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_box.png"]];
	_loginBox.frame = CGRectMake( 65, 193, 230, 75 );
	[self.view addSubview:_loginBox];
	
	self.emailInput = [[UITextField alloc] initWithFrame:CGRectMake( 75, 203, 245, 31 )];
	self.emailInput.delegate = self;
	self.emailInput.placeholder = NSLocalizedString( @"EMAIL", @"" );
	self.emailInput.font = [UIFont boldSystemFontOfSize:13];
	self.emailInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	self.emailInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	self.emailInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	self.emailInput.layer.shadowOpacity = 1;
	self.emailInput.layer.shadowRadius = 0;
	self.emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailInput.returnKeyType = UIReturnKeyNext;
	self.emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[self.emailInput setValue:[UIColor colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[self.emailInput addTarget:self action:@selector(inputEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	[self.emailInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:self.emailInput];
	
	_passwordInput = [[UITextField alloc] initWithFrame:CGRectMake( 75, 240, 245, 31 )];
	_passwordInput.delegate = self;
	_passwordInput.placeholder = NSLocalizedString( @"PASSWORD", @"" );
	_passwordInput.font = [UIFont boldSystemFontOfSize:13];
	_passwordInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_passwordInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_passwordInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_passwordInput.layer.shadowOpacity = 1;
	_passwordInput.layer.shadowRadius = 0;
	_passwordInput.secureTextEntry = YES;
	_passwordInput.returnKeyType = UIReturnKeyGo;
	[_passwordInput setValue:[UIColor colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[_passwordInput addTarget:self action:@selector(inputEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	[_passwordInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:_passwordInput];
	
	_loginButton = [[UIButton alloc] initWithFrame:CGRectMake( 65, 290, 230, 40 )];
	_loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	_loginButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_loginButton setTitle:NSLocalizedString( @"LOGIN", @"" ) forState:UIControlStateNormal];
	[_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_loginButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[_loginButton setBackgroundImage:[UIImage imageNamed:@"login_button.png"] forState:UIControlStateNormal];
	[_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_loginButton];
	
	_facebookLoginButton = [[UIButton alloc] initWithFrame:CGRectMake( 65, 340, 230, 40 )];
	_facebookLoginButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	_facebookLoginButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_facebookLoginButton setTitle:NSLocalizedString( @"LOGIN_WITH_FACEBOOK", @"" ) forState:UIControlStateNormal];
	[_facebookLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_facebookLoginButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[_facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"login_facebook_button.png"] forState:UIControlStateNormal];
	[_facebookLoginButton addTarget:self action:@selector(facebookLoginButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_facebookLoginButton];
	
	_signUpButton = [[UIButton alloc] initWithFrame:CGRectMake( 65, 390, 230, 40 )];
	_signUpButton.titleLabel.font = [UIFont systemFontOfSize:13];
	_signUpButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_signUpButton setTitle:NSLocalizedString( @"NO_ACCOUNT", nil ) forState:UIControlStateNormal];
	[_signUpButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[_signUpButton addTarget:self action:@selector(signUpButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_signUpButton];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}


#pragma mark -
#pragma mark Animations

- (void)animateUp
{
	[UIView animateWithDuration:0.25 animations:^{
		_forkAndKnife.frame = CGRectMake( 140, 10, 80, 90 );
		_loginBox.frame = CGRectMake( 65, 108, 230, 75 );
		self.emailInput.frame = CGRectMake( 75, 118, 245, 31 );
		_passwordInput.frame = CGRectMake( 75, 155, 245, 31 );
		_loginButton.frame = CGRectMake( 65, 195, 230, 40 );
		_facebookLoginButton.frame = CGRectMake( 65, 245, 230, 40 );
		_signUpButton.frame = CGRectMake( 65, 295, 230, 40 );
	}];
}

- (void)animateDown
{
	[UIView animateWithDuration:0.25 animations:^{
		_forkAndKnife.frame = CGRectMake( 140, 55, 80, 90 );
		_loginBox.frame = CGRectMake( 65, 193, 230, 75 );
		self.emailInput.frame = CGRectMake( 75, 203, 245, 31 );
		_passwordInput.frame = CGRectMake( 75, 240, 245, 31 );
		_loginButton.frame = CGRectMake( 65, 290, 230, 40 );
		_facebookLoginButton.frame = CGRectMake( 65, 340, 230, 40 );
		_signUpButton.frame = CGRectMake( 65, 390, 230, 40 );
	}];
}


#pragma mark -
#pragma mark Selectors

- (void)closeButtonDidTouchUpInside
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bgViewDidTouchDown
{
	[self.emailInput resignFirstResponder];
	[_passwordInput resignFirstResponder];
	[self animateDown];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)inputEditingDidBegin
{
	[self animateUp];
}

- (void)inputEditChanged:(id)sender
{
	UITextField *input = (UITextField *)sender;
	
	if( input.text.length > 0 )
		input.font = [UIFont systemFontOfSize:15];
	else
		input.font = [UIFont boldSystemFontOfSize:15];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if( textField == self.emailInput )
	{
		[_passwordInput becomeFirstResponder];
		return NO;
	}
	
	[self login];
	
	return NO;
}


#pragma mark -
#pragma mark Login

- (void)login
{
	NSString *email = self.emailInput.text;
	if( email.length == 0 )
	{
		[self.emailInput becomeFirstResponder];
		return;
	}
	
	NSString *password = [Utils sha1:_passwordInput.text];
	if( password.length == 0 )
	{
		[_passwordInput becomeFirstResponder];
		return;
	}
	
	[self dim];
	
	NSDictionary *params = @{ @"email": email, @"password": password };
	[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
		JLLog( @"Login succeeded" );
		
		[CurrentUser user].loggedIn = YES;
		[CurrentUser user].accessToken = [response objectForKey:@"access_token"];
		[self getUser];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"Login failed : %@", message );
		[self undim];
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"MESSAGE_LOGIN_FAILED", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] show];
	}];
	
	[self.emailInput resignFirstResponder];
	[_passwordInput resignFirstResponder];
	[self animateDown];
}


#pragma mark -
#pragma mark Facebook Login

- (void)facebookLoginButtonDidTouchUpInside
{
	[self dim];
	
	[FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
		JLLog( @"status : %d", status );
		switch( status )
		{
			case FBSessionStateOpen:
			{
				// 로그인을 먼저 요청
				NSDictionary *params = @{ @"facebook_token": [[FBSession activeSession] accessToken] };
				[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
					[CurrentUser user].loggedIn = YES;
					[CurrentUser user].accessToken = [response objectForKey:@"access_token"];
					[self getUser];
					
				} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
					
					// 해당 계정이 없다면 회원가입 요청을 보낸다
					if( errorCode == 4100 )
					{
						[[DMAPILoader sharedLoader] api:@"/user" method:@"POST" parameters:params success:^(id response) {
							JLLog( @"SignUp complete" );
							
							// 회원가입이 완료되면 로그인
							[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
								[self undim];
								
								[CurrentUser user].loggedIn = YES;
								[CurrentUser user].accessToken = [response objectForKey:@"access_token"];
								
								[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"WELCOME", nil ) message:NSLocalizedString( @"MESSAGE_SIGNUP_COMPLETE", nil ) cancelButtonTitle:NSLocalizedString( @"DO_IT_LATER", nil ) otherButtonTitles:@[NSLocalizedString( @"YES", nil )] dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
									
									// 나중에 하기
									if( buttonIndex == 0 )
									{
										[self getUser];
									}
									else
									{
										NSInteger userId = [[response objectForKey:@"id"] integerValue];
										SignUpStepTwoViewController *signUpViewController = [[SignUpStepTwoViewController alloc] initWithUserId:userId facebookAccessToken:[[FBSession activeSession] accessToken]];
										[self.navigationController pushViewController:signUpViewController animated:YES];
									}
								}] show];
								
							} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
								[self undim];
								showErrorAlert();
							}];
							
						} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
							[self undim];
							showErrorAlert();
						}];
					}
					else
					{
						[self undim];
						showErrorAlert();
					}
				}];
				break;
			}
				
			case FBSessionStateClosedLoginFailed:
				[self undim];
				JLLog( @"FBSessionStateClosedLoginFailed (User canceled login to facebook)" );
				break;
		}
	}];
}


#pragma mark -
#pragma mark Get User

- (void)getUser
{
	JLLog( @"getUser" );
	[[DMAPILoader sharedLoader] api:@"/user" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"getUser success" );
		
		[self undim];
		
		[[CurrentUser user] updateToDictionary:response];
		[[CurrentUser user] save];
		
		[self.delegate loginViewControllerDidSucceedLogin:self];
		[self dismissViewControllerAnimated:YES completion:nil];
		
		[[FBSession activeSession] closeAndClearTokenInformation];
		
		[[DMAPILoader sharedLoader] loadImageFromURL:[NSURL URLWithString:[response objectForKey:@"photo_url"]] context:nil success:^(UIImage *image, id context) {
			JLLog( @"Image loading succeeded" );
			[CurrentUser user].photo = image;
		}];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self undim];
		showErrorAlert();
	}];
}


#pragma mark -
#pragma mark Sign Up

- (void)signUpButtonDidTouchUpInside
{
	SignUpStepOneViewController *signUpViewController = [[SignUpStepOneViewController alloc] init];
	[self.navigationController pushViewController:signUpViewController animated:YES];
}

@end
