//
//  LoginViewController.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "LoginViewController.h"
#import "DishByMeBarButtonItem.h"
#import "Utils.h"
#import "Const.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingsManager.h"

@implementation LoginViewController

- (id)initWithTarget:(id)_target action:(SEL)_action
{
	self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	DishByMeBarButtonItem *cancelButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];
	[gestureRecognizer release];
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.png"]];
	[self.view addSubview:bgView];
	[bgView release];
	
	UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake( 280, 15, 26, 26 )];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"login_close_button.png"] forState:UIControlStateNormal];
	[self.view addSubview:closeButton];
	[closeButton release];
	
	forkAndKnife = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fork_knife.png"]];
	forkAndKnife.frame = CGRectMake( 140, 55, 80, 90 );
	[self.view addSubview:forkAndKnife];
	[forkAndKnife release];
	
	loginBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_box.png"]];
	loginBox.frame = CGRectMake( 65, 193, 230, 75 );
	[self.view addSubview:loginBox];
	[loginBox release];
	
	emailInput = [[UITextField alloc] initWithFrame:CGRectMake( 75, 203, 245, 31 )];
	emailInput.delegate = self;
	emailInput.placeholder = NSLocalizedString( @"EMAIL", @"" );
	emailInput.font = [UIFont boldSystemFontOfSize:13];
	emailInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	emailInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	emailInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	emailInput.layer.shadowOpacity = 1;
	emailInput.layer.shadowRadius = 0;
	emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	emailInput.returnKeyType = UIReturnKeyNext;
	emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
	emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[emailInput setValue:[Utils colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[emailInput addTarget:self action:@selector(inputEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	[emailInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:emailInput];
	[emailInput release];
	
	passwordInput = [[UITextField alloc] initWithFrame:CGRectMake( 75, 240, 245, 31 )];
	passwordInput.delegate = self;
	passwordInput.placeholder = NSLocalizedString( @"PASSWORD", @"" );
	passwordInput.font = [UIFont boldSystemFontOfSize:13];
	passwordInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	passwordInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	passwordInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	passwordInput.layer.shadowOpacity = 1;
	passwordInput.layer.shadowRadius = 0;
	passwordInput.secureTextEntry = YES;
	passwordInput.returnKeyType = UIReturnKeyGo;
	[passwordInput setValue:[Utils colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[passwordInput addTarget:self action:@selector(inputEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	[passwordInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:passwordInput];
	[passwordInput release];
	
	loginButton = [[UIButton alloc] initWithFrame:CGRectMake( 65, 290, 230, 40 )];
	[loginButton setBackgroundImage:[UIImage imageNamed:@"login_button.png"] forState:UIControlStateNormal];
	[self.view addSubview:loginButton];
	[loginButton release];
	
	facebookLoginButton = [[UIButton alloc] initWithFrame:CGRectMake( 65, 340, 230, 40 )];
	[facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"login_facebook_button.png"] forState:UIControlStateNormal];
	[self.view addSubview:facebookLoginButton];
	[facebookLoginButton release];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	target = _target;
	action = _action;
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Animations

- (void)animateUp
{
	[UIView animateWithDuration:0.25 animations:^{
		forkAndKnife.frame = CGRectMake( 140, 10, 80, 90 );
		loginBox.frame = CGRectMake( 65, 108, 230, 75 );
		emailInput.frame = CGRectMake( 75, 118, 245, 31 );
		passwordInput.frame = CGRectMake( 75, 155, 245, 31 );
		loginButton.frame = CGRectMake( 65, 195, 230, 40 );
		facebookLoginButton.frame = CGRectMake( 65, 245, 230, 40 );
	}];
}

- (void)animateDown
{
	[UIView animateWithDuration:0.25 animations:^{
		forkAndKnife.frame = CGRectMake( 140, 55, 80, 90 );
		loginBox.frame = CGRectMake( 65, 193, 230, 75 );
		emailInput.frame = CGRectMake( 75, 203, 245, 31 );
		passwordInput.frame = CGRectMake( 75, 240, 245, 31 );
		loginButton.frame = CGRectMake( 65, 290, 230, 40 );
		facebookLoginButton.frame = CGRectMake( 65, 340, 230, 40 );
	}];
}


#pragma mark -
#pragma mark Selectors

- (void)cancelButtonDidTouchUpInside
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
	[emailInput resignFirstResponder];
	[passwordInput resignFirstResponder];
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
	if( textField == emailInput )
	{
		[passwordInput becomeFirstResponder];
		return NO;
	}
	
	NSString *email = emailInput.text;
	if( email.length == 0 )
	{
		[emailInput becomeFirstResponder];
		return NO;
	}
	
	NSString *password = passwordInput.text;
	if( password.length == 0 )
	{
		[passwordInput becomeFirstResponder];
		return NO;
	}
	
	[self loginWithEmail:email password:[Utils sha1:password]];
	[textField resignFirstResponder];
	[self animateDown];
	
	return NO;
}


#pragma mark -
#pragma mark Login

- (void)signUpButtonDidTouchUpInside
{
//	SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
//	[self.navigationController pushViewController:signUpViewController animated:YES];
//	[signUpViewController release];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password
{
	NSString *rootUrl = API_ROOT_URL;
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
	[loader addTokenWithTokenId:0 url:[NSString stringWithFormat:@"%@/auth", rootUrl] method:APILoaderMethodGET params:params];
	[loader startLoading];
}


#pragma mark -
#pragma mark APILoader

- (BOOL)shouldLoadWithToken:(APILoaderToken *)token
{
	return YES;
}

- (void)loadingDidFinish:(APILoaderToken *)token
{
	NSDictionary *data = [Utils parseJSON:token.data];
	
	if( [data objectForKey:@"error"] )
	{
		[[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"LOGIN_FAILED_MSG", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] autorelease] show];
		return;
	}
	
	[[SettingsManager manager] setSetting:[data objectForKey:@"access_token"] forKey:SETTING_KEY_ACCESS_TOKEN];
	[[SettingsManager manager] setSetting:emailInput.text forKey:SETTING_KEY_EMAIL];
	[[SettingsManager manager] setSetting:passwordInput.text forKey:SETTING_KEY_PASSWORD];
	[[SettingsManager manager] setSetting:(NSNumber *)[data objectForKey:@"user_id"] forKey:SETTING_KEY_USER_ID];
	[[SettingsManager manager] flush];
	
	[target performSelector:action];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
