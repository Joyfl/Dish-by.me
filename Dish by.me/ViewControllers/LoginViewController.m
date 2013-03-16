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
#import "UserManager.h"
#import "User.h"
#import "JLHTTPLoader.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DMAPILoader.h"
#import "UIViewController+Dim.h"

#define showErrorAlert() [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Status Code : %d\nError Code : %d\nMessage : %@", statusCode, errorCode, message] delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];

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
	
	_emailInput = [[UITextField alloc] initWithFrame:CGRectMake( 75, 203, 245, 31 )];
	_emailInput.delegate = self;
	_emailInput.placeholder = NSLocalizedString( @"EMAIL", @"" );
	_emailInput.font = [UIFont boldSystemFontOfSize:13];
	_emailInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_emailInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_emailInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_emailInput.layer.shadowOpacity = 1;
	_emailInput.layer.shadowRadius = 0;
	_emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	_emailInput.returnKeyType = UIReturnKeyNext;
	_emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
	_emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[_emailInput setValue:[UIColor colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[_emailInput addTarget:self action:@selector(inputEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	[_emailInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:_emailInput];
	
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
	
	return self;
}


#pragma mark -
#pragma mark Animations

- (void)animateUp
{
	[UIView animateWithDuration:0.25 animations:^{
		_forkAndKnife.frame = CGRectMake( 140, 10, 80, 90 );
		_loginBox.frame = CGRectMake( 65, 108, 230, 75 );
		_emailInput.frame = CGRectMake( 75, 118, 245, 31 );
		_passwordInput.frame = CGRectMake( 75, 155, 245, 31 );
		_loginButton.frame = CGRectMake( 65, 195, 230, 40 );
		_facebookLoginButton.frame = CGRectMake( 65, 245, 230, 40 );
	}];
}

- (void)animateDown
{
	[UIView animateWithDuration:0.25 animations:^{
		_forkAndKnife.frame = CGRectMake( 140, 55, 80, 90 );
		_loginBox.frame = CGRectMake( 65, 193, 230, 75 );
		_emailInput.frame = CGRectMake( 75, 203, 245, 31 );
		_passwordInput.frame = CGRectMake( 75, 240, 245, 31 );
		_loginButton.frame = CGRectMake( 65, 290, 230, 40 );
		_facebookLoginButton.frame = CGRectMake( 65, 340, 230, 40 );
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
	[_emailInput resignFirstResponder];
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
	if( textField == _emailInput )
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
	[self dim];
	
	NSString *email = _emailInput.text;
	if( email.length == 0 )
	{
		[_emailInput becomeFirstResponder];
		return;
	}
	
	NSString *password = [Utils sha1:_passwordInput.text];
	if( password.length == 0 )
	{
		[_passwordInput becomeFirstResponder];
		return;
	}
	
	NSDictionary *params = @{ @"email": email, @"password": password };
	[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
		JLLog( @"Login succeeded" );
		
		[UserManager manager].loggedIn = YES;
		[[UserManager manager] setAccessToken:[response objectForKey:@"access_token"]];
		[self getUser];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"Login failed : %@", message );
		[self undim];
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"MESSAGE_LOGIN_FAILED", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] show];
	}];
	
	[_emailInput resignFirstResponder];
	[_passwordInput resignFirstResponder];
	[self animateDown];
}


#pragma mark -
#pragma mark Facebook Login

- (void)facebookLoginButtonDidTouchUpInside
{
	[self dim];
	
	[FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
		switch( status )
		{
			case FBSessionStateOpen:
			{
				// Facebook 회원가입을 먼저 요청
				NSDictionary *params = @{ @"facebook_token": [[FBSession activeSession] accessToken] };
				[[DMAPILoader sharedLoader] api:@"/user" method:@"POST" parameters:params success:^(id response) {
#warning 프로필 완성단계로 넘어가기
					JLLog( @"Sign up complete" );
					
					[self undim];
					[[[UIAlertView alloc] initWithTitle:nil message:@"회원가입 완료. [페이스북으로 로그인] 버튼을 다시 눌러주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
					
				} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
					// 중복된 계정이 있다면 로그인 요청을 보낸다
					if( errorCode == 1400 )
					{
						[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
							[UserManager manager].loggedIn = YES;
							[[UserManager manager] setAccessToken:[response objectForKey:@"access_token"]];
							[self getUser];
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
				
			default:
				NSLog( @"%d", status );
				[self undim];
				break;
		}
	}];
}


#pragma mark -
#pragma mark Get User

- (void)getUser
{
	[[DMAPILoader sharedLoader] api:@"/user" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"getUser success" );
		
		[self undim];
		
		[UserManager manager].userId = [[response objectForKey:@"id"] integerValue];
		[UserManager manager].userName = [response objectForKey:@"name"];
		
		[self dismissViewControllerAnimated:YES completion:nil];
		[self.delegate loginViewControllerDidSucceedLogin:self];
		
		[[DMAPILoader sharedLoader] loadImageFromURL:[NSURL URLWithString:[response objectForKey:@"photo_url"]] context:nil success:^(UIImage *image, id context) {
			JLLog( @"Image loading succeeded" );
			[UserManager manager].userPhoto = image;
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
//	SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
//	[self.navigationController pushViewController:signUpViewController animated:YES];
//	[signUpViewController release];
}

@end
