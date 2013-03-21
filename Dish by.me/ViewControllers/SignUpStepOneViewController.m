//
//  SignUpViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 18..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "SignUpStepOneViewController.h"
#import "SignUpProfileViewController.h"
#import "DMBarButtonItem.h"
#import <QuartzCore/CALayer.h>
#import "DMAPILoader.h"
#import "UIViewController+Dim.h"
#import "HTBlock.h"
#import "LoginViewController.h"
#import "CurrentUser.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation SignUpStepOneViewController

- (id)init
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [self.class description];
	
	[DMBarButtonItem setBackButtonToViewController:self viewControllerWillBePopped:^{
		if( _isLastErrorAlreadySignedUp )
		{
			[(LoginViewController *)[self.navigationController.viewControllers objectAtIndex:0] emailInput].text = _emailInput.text;
			[self.navigationController popViewControllerAnimated:YES];
		}
	}];
	self.navigationItem.title = NSLocalizedString( @"SIGNUP", nil );
	self.navigationItem.rightBarButtonItem = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"DONE", nil ) target:self action:@selector(signUp)];
	
	UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 20, 280, 0 )];
	messageLabel.text = NSLocalizedString( @"MESSAGE_SIGNUP_STEP_ONE", nil );
	messageLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
	messageLabel.font = [UIFont systemFontOfSize:14];
	messageLabel.numberOfLines = 0;
	messageLabel.backgroundColor = [UIColor clearColor];
	[messageLabel sizeToFit];
	[self.view addSubview:messageLabel];
	
	_emailInput = [[UITextField alloc] initWithFrame:CGRectMake( 20, 73, 280, 31 )];
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
	[_emailInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[_emailInput becomeFirstResponder];
	[self.view addSubview:_emailInput];
	
	_passwordInput = [[UITextField alloc] initWithFrame:CGRectMake( 20, 110, 280, 31 )];
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
	[_passwordInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:_passwordInput];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate

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
	
	[self signUp];
	
	return NO;
}


#pragma mark -
#pragma mark API

- (void)signUp
{
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
	
	[_emailInput resignFirstResponder];
	[_passwordInput resignFirstResponder];
	
	[self dim];
	
	NSDictionary *params = @{ @"email": email, @"password": password };
	[[DMAPILoader sharedLoader] api:@"/user" method:@"POST" parameters:params success:^(id response) {
		
		// 회원가입이 완료되면 로그인
		[[DMAPILoader sharedLoader] api:@"/auth/login" method:@"GET" parameters:params success:^(id response) {
			[self undim];
			
			[CurrentUser user].loggedIn = YES;
			[CurrentUser user].accessToken = [response objectForKey:@"access_token"];
			
			NSMutableDictionary *sharingSettings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:DMUserDefaultsKeySharingSettings]];
			if( !sharingSettings ) sharingSettings = [NSMutableDictionary dictionary];
			[sharingSettings setObject:[NSNumber numberWithBool:YES] forKey:@"facebook"];
			[[NSUserDefaults standardUserDefaults] setObject:sharingSettings forKey:DMUserDefaultsKeySharingSettings];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"WELCOME", nil ) message:NSLocalizedString( @"MESSAGE_SIGNUP_COMPLETE", nil ) cancelButtonTitle:NSLocalizedString( @"YES", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
				
				NSInteger userId = [[response objectForKey:@"id"] integerValue];
				SignUpProfileViewController *signUpStepTwoViewController = [[SignUpProfileViewController alloc] initWithUserId:userId];
				[self.navigationController pushViewController:signUpStepTwoViewController animated:YES];
				
			}] show];
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			JLLog( @"Login failed after sign up." );
		}];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
		// 이미 가입된 계정
		if( errorCode == 1400 )
		{
			[self undimAnimated:NO];
			
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_ALREADY_SIGNED_UP", nil ) cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
				_isLastErrorAlreadySignedUp = YES;
				[_emailInput becomeFirstResponder];
				
			}] show];
		}
		else
		{
			[_emailInput becomeFirstResponder];
			[self undim];
		}
	}];
}


#pragma mark -
#pragma mark Get User

- (void)getUser
{
	[self dim];
	
	JLLog( @"getUser" );
	[[DMAPILoader sharedLoader] api:@"/user" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"getUser success" );
		
		[self undim];
		
		[[CurrentUser user] updateToDictionary:response];
		[[CurrentUser user] save];
		
		LoginViewController *loginViewController = [self.navigationController.viewControllers objectAtIndex:0];
		[loginViewController.delegate loginViewControllerDidSucceedLogin:loginViewController];
		
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

@end
