//
//  SignUpViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "SignUpViewController.h"
#import "DMBookButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+Dim.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CurrentUser.h"
#import "HTBlock.h"
#import "SignUpStepTwoViewController.h"
#import "LoginViewController.h"

@implementation SignUpViewController

- (id)init
{
	self = [super init];
	self.trackedViewName = [self.class description];
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)]];
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	bgView.image = [UIImage imageNamed:@"book_background.png"];
	[self.view addSubview:bgView];
	
	UIImageView *paperView = [[UIImageView alloc] initWithFrame:CGRectMake( 7, 7, 305, UIScreenHeight - 85 )];
	paperView.image = [[UIImage imageNamed:@"book_paper.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 10, 10, 10, 10 )];
	[self.view addSubview:paperView];
	
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake( 30, 35, 9, 15 )];
	[backButton setBackgroundImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(backButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = NSLocalizedString( @"SIGNUP", nil );
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	titleLabel.textColor = [UIColor colorWithHex:0x4B4A47 alpha:1];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[titleLabel sizeToFit];
	titleLabel.frame = CGRectOffset( titleLabel.frame, 160 - titleLabel.frame.size.width / 2, 30 );
	[self.view addSubview:titleLabel];
	
	DMBookButton *facebookButton = [DMBookButton blueBookButtonWithPosition:CGPointMake( 30, 65 ) title:NSLocalizedString( @"SIGNUP_WITH_FACEBOOK", nil )];
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
	[self.view addSubview:_emailInput];
	
	_passwordInput = [self inputFieldAtYPosition:_emailInput.frame.origin.y + 40 placeholder:NSLocalizedString( @"PASSWORD", nil )];
	[self.view addSubview:_passwordInput];
	
	_passwordConfirmationInput = [self inputFieldAtYPosition:_passwordInput.frame.origin.y + 40 placeholder:NSLocalizedString( @"CONFIRM_PASSWORD", nil )];
	[self.view addSubview:_passwordConfirmationInput];
	
	for( NSInteger i = 0; i < 3; i++ )
	{
		UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 27, 175 + 40 * i, 265, 5 )];
		lineView.image = [UIImage imageNamed:@"book_line.png"];
		[self.view addSubview:lineView];
	}
	
	DMBookButton *signUpButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, 287 ) title:NSLocalizedString( @"SIGNUP", nil )];
	[signUpButton addTarget:self action:@selector(signUpButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:signUpButton];
	
	UILabel *agreementLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 260, 0 )];
	agreementLabel.text = NSLocalizedString( @"MESSAGE_AGREEMENT", nil );
	agreementLabel.font = [UIFont boldSystemFontOfSize:12];
	agreementLabel.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	agreementLabel.textAlignment = NSTextAlignmentCenter;
	agreementLabel.backgroundColor = [UIColor clearColor];
	agreementLabel.shadowColor = [UIColor whiteColor];
	agreementLabel.shadowOffset = CGSizeMake( 0, 1 );
	agreementLabel.numberOfLines = 0;
	[agreementLabel sizeToFit];
	agreementLabel.frame = CGRectOffset( agreementLabel.frame, 160 - agreementLabel.frame.size.width / 2, signUpButton.frame.origin.y + signUpButton.frame.size.height + 17 );
	[agreementLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementLabelDidTap)]];
	[self.view addSubview:agreementLabel];
	
	return self;
}

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (UITextField *)inputFieldAtYPosition:(CGFloat)y placeholder:(NSString *)placeholder
{
	UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake( 30, y, 260, 20 )];
	inputField.placeholder = placeholder;
	inputField.font = [UIFont boldSystemFontOfSize:13];
	inputField.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	inputField.backgroundColor = [UIColor clearColor];
	inputField.layer.shadowOffset = CGSizeMake( 0, 1 );
	inputField.layer.shadowColor = [UIColor whiteColor].CGColor;
	inputField.layer.shadowOpacity = 1;
	inputField.layer.shadowRadius = 1;
	inputField.keyboardType = UIKeyboardTypeEmailAddress;
	inputField.returnKeyType = UIReturnKeyNext;
	inputField.autocorrectionType = UITextAutocorrectionTypeNo;
	inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[inputField addTarget:self action:@selector(inputFieldEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	return inputField;
}

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
				NSDictionary *params = @{ @"facebook_token": [[FBSession activeSession] accessToken] };
				[[DMAPILoader sharedLoader] api:@"/user" method:@"POST" parameters:params success:^(id response) {
					JLLog( @"SignUp complete" );
					
					// 회원가입이 완료되면 로그인
					[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
						[self undim];
						
						[CurrentUser user].loggedIn = YES;
						[CurrentUser user].accessToken = [response objectForKey:@"access_token"];
						
						[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"WELCOME", nil ) message:NSLocalizedString( @"MESSAGE_SIGNUP_COMPLETE", nil ) cancelButtonTitle:NSLocalizedString( @"YES", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
							NSInteger userId = [[response objectForKey:@"id"] integerValue];
							SignUpStepTwoViewController *signUpViewController = [[SignUpStepTwoViewController alloc] initWithUserId:userId facebookAccessToken:[[FBSession activeSession] accessToken]];
							[self.navigationController pushViewController:signUpViewController animated:YES];
						}] show];
						
					} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
						[self undim];
						showErrorAlert();
					}];
					
				} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
					[self undim];
					
					// 이미 가입된 사용자
					if( errorCode == 1400 )
					{
						[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_ALREADY_SIGNED_UP", nil ) cancelButtonTitle:NSLocalizedString( @"NO_THANKS", nil ) otherButtonTitles:@[NSLocalizedString( @"LOGIN", nil )] dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
							
							// 로그인
							if( buttonIndex == 1 )
							{
								LoginViewController *loginViewController = [[LoginViewController alloc] init];
								[self.navigationController pushViewController:loginViewController animated:YES];
							}
						}] show];
						return;
					}
					
					showErrorAlert();
				}];
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

- (void)signUpButtonDidTouchUpInside
{
	
}

- (void)agreementLabelDidTap
{
	
}

@end
