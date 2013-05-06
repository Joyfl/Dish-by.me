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
#import "SignUpProfileViewController.h"
#import "HTBlock.h"
#import "AuthViewController.h"
#import "UIButton+TouchAreaInsets.h"
#import "UIButton+ActivityIndicatorView.h"
#import "ForgotPasswordViewController.h"

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
	
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake( 28, 33, 12, 18 )];
	backButton.touchAreaInsets = UIEdgeInsetsMake( 15, 15, 15, 15 );
	[backButton setBackgroundImage:[UIImage imageNamed:@"book_button_back.png"] forState:UIControlStateNormal];
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
	
	_facebookButton = [DMBookButton blueBookButtonWithPosition:CGPointMake( 30, 65 ) title:NSLocalizedString( @"LOGIN_WITH_FACEBOOK", nil )];
	[_facebookButton addTarget:self action:@selector(facebookButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_facebookButton];
	
	UILabel *orLabel = [[UILabel alloc] init];
	orLabel.text = NSLocalizedString( @"OR", nil );
	orLabel.font = [UIFont boldSystemFontOfSize:13];
	orLabel.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	orLabel.textAlignment = NSTextAlignmentCenter;
	orLabel.backgroundColor = [UIColor clearColor];
	orLabel.shadowColor = [UIColor whiteColor];
	orLabel.shadowOffset = CGSizeMake( 0, 1 );
	[orLabel sizeToFit];
	orLabel.frame = CGRectOffset( orLabel.frame, 160 - orLabel.frame.size.width / 2, _facebookButton.frame.origin.y + _facebookButton.frame.size.height + 15 );
	[self.view addSubview:orLabel];
	
	self.emailInput = [self inputFieldAtYPosition:150 placeholder:NSLocalizedString( @"EMAIL", nil )];
	self.emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailInput.returnKeyType = UIReturnKeyNext;
	[self.emailInput addTarget:self action:@selector(inputFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:self.emailInput];
	
	_passwordInput = [self inputFieldAtYPosition:self.emailInput.frame.origin.y + 40 placeholder:NSLocalizedString( @"PASSWORD", nil )];
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
	
	//
	// 추후 업데이트
	//
	_forgotPasswordButton = [[UIButton alloc] init];
	_forgotPasswordButton.titleLabel.font = [UIFont systemFontOfSize:12];
	_forgotPasswordButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_forgotPasswordButton setTitle:NSLocalizedString( @"FORGOT_PASSWORD", nil ) forState:UIControlStateNormal];
	[_forgotPasswordButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_forgotPasswordButton setTitleColor:[UIColor colorWithHex:0x4B4A47 alpha:1] forState:UIControlStateNormal];
	[_forgotPasswordButton sizeToFit];
	_forgotPasswordButton.center = CGPointMake( UIScreenWidth / 2, 310 );
	[_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:_forgotPasswordButton];
	
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
	inputField.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
	[inputField setValue:[UIColor colorWithHex:0xADA8A3 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
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
	self.emailInput.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
	
	if( inputField.text.length == 0 )
	{
		[inputField setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	}
	
	_loginButton.enabled = self.emailInput.text.length > 0 && _passwordInput.text.length > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if( textField.text.length > 0 )
	{
		if( textField == self.emailInput )
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
		self.view.frame = CGRectMake( 0, IPHONE5 ? 0 : -55, self.view.frame.size.width, self.view.frame.size.height );
	}];
}

- (void)facebookButtonDidTouchUpInside
{
	[self setInputFieldsEnabled:NO];
	_facebookButton.showsActivityIndicatorView = YES;
	
	FBSession *session = [[FBSession alloc] initWithAppID:@"115946051893330" permissions:@[@"publish_actions", @"email"] defaultAudience:FBSessionDefaultAudienceEveryone urlSchemeSuffix:nil tokenCacheStrategy:nil];
	[FBSession setActiveSession:session];
	[session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
		
		switch( status )
		{
			case FBSessionStateOpen:
			{
				JLLog( @"openWithCompletionHandler with publish permissions complete." );
				[self loginWithParameters:@{ @"facebook_token": [[FBSession activeSession] accessToken] }];
				break;
			}
				
			case FBSessionStateOpenTokenExtended:
			{
				JLLog( @"FBSessionStateOpenTokenExtended" );
				break;
			}
				
			case FBSessionStateClosedLoginFailed:
				[self setInputFieldsEnabled:YES];
				_facebookButton.showsActivityIndicatorView = NO;
				
				[[FBSession activeSession] closeAndClearTokenInformation];
				JLLog( @"FBSessionStateClosedLoginFailed (User canceled login to facebook)" );
				break;
				
			default:
				[self setInputFieldsEnabled:YES];
				_facebookButton.showsActivityIndicatorView = NO;
				break;
		}
		
		if( error )
		{
			if( error.code == 2 )
			{
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_FACEBOOK_NOT_ALLOWED", nil ) delegate:nil cancelButtonTitle:NSLocalizedString( @"YES", nil ) otherButtonTitles:nil] show];
			}
			else
			{
				JLLog( @"Facebook Error : %@", error );
			}
		}
	}];
}

- (void)loginButtonDidTouchUpInside
{	
	if( self.emailInput.text.length == 0 )
	{
		[self.emailInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[self.emailInput becomeFirstResponder];
		return;
	}
	
	if( _passwordInput.text.length == 0 )
	{
		[_passwordInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[_passwordInput becomeFirstResponder];
		return;
	}
	
	[self backgroundDidTap];
	_loginButton.showsActivityIndicatorView = YES;
	[self loginWithParameters:@{ @"email": self.emailInput.text, @"password": [Utils sha1:_passwordInput.text] }];
}

- (void)loginWithParameters:(NSDictionary *)parameters
{
	JLLog( @"Login parameters : %@", parameters );
	
	[self setInputFieldsEnabled:NO];
	
	[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"POST" parameters:parameters success:^(id response) {
		JLLog( @"Login complete" );
		
		[CurrentUser user].loggedIn = YES;
		[CurrentUser user].email = [[response objectForKeyNotNull:@"user"] objectForKeyNotNull:@"email"];
		[CurrentUser user].accessToken = [response objectForKeyNotNull:@"access_token"];
		
		[(AuthViewController *)[self.navigationController.viewControllers objectAtIndex:0] getUser];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		_loginButton.showsActivityIndicatorView = NO;
		_facebookButton.showsActivityIndicatorView = NO;
		[self setInputFieldsEnabled:YES];
		
		// 존재하지 않는 사용자
		if( errorCode == 4100 )
		{
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_INVALID_USER", nil ) cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
				[_emailInput becomeFirstResponder];
			}] show];
		}
		
		// 패스워드 틀림
		else if( errorCode == 3100 )
		{
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_WRONG_PASSWORD", nil ) cancelButtonTitle:NSLocalizedString( @"OH_MY_MISTAKE", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
				[_passwordInput becomeFirstResponder];
			}] show];
		}
		
		else
		{
			showErrorAlert();
		}
	}];
}

- (void)setInputFieldsEnabled:(BOOL)inputFieldsEnabled
{
	if( inputFieldsEnabled )
	{
		self.emailInput.enabled = YES;
		_passwordInput.enabled = YES;
	}
	else
	{
		self.emailInput.enabled = NO;
		_passwordInput.enabled = NO;
	}
}


#pragma mark -

- (void)forgotPasswordButtonDidTouchUpInside
{
	ForgotPasswordViewController *forgotPasswordViewController = [[ForgotPasswordViewController alloc] init];
	forgotPasswordViewController.emailInput.text = _emailInput.text;
	[self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}

@end
