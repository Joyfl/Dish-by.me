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
	
	emailInput = [[UITextField alloc] initWithFrame:CGRectMake( 38, 162, 245, 31 )];
	emailInput.delegate = self;
	emailInput.placeholder = NSLocalizedString( @"EMAIL", @"" );
	emailInput.font = [UIFont boldSystemFontOfSize:15];
	emailInput.textColor = [UIColor colorWithRed:0.392 green:0.313 blue:0.250 alpha:1.0];
	emailInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	emailInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	emailInput.layer.shadowOpacity = 0.5;
	emailInput.layer.shadowRadius = 0;
	emailInput.keyboardType = UIKeyboardTypeEmailAddress;
	emailInput.returnKeyType = UIReturnKeyNext;
	emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
	emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[emailInput setValue:[UIColor colorWithRed:0.788 green:0.635 blue:0.517 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
	[emailInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:emailInput];
	[emailInput release];
	
	passwordInput = [[UITextField alloc] initWithFrame:CGRectMake( 38, 203, 245, 31 )];
	passwordInput.delegate = self;
	passwordInput.placeholder = NSLocalizedString( @"PASSWORD", @"" );
	passwordInput.font = [UIFont boldSystemFontOfSize:15];
	passwordInput.textColor = [UIColor colorWithRed:0.392 green:0.313 blue:0.250 alpha:1.0];
	passwordInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	passwordInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	passwordInput.layer.shadowOpacity = 0.5;
	passwordInput.layer.shadowRadius = 0;
	passwordInput.secureTextEntry = YES;
	passwordInput.returnKeyType = UIReturnKeyGo;
	[passwordInput setValue:[UIColor colorWithRed:0.788 green:0.635 blue:0.517 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
	[passwordInput addTarget:self action:@selector(inputEditChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:passwordInput];
	[passwordInput release];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	target = _target;
	action = _action;
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
//	self.navigationController.navigationBarHidden = YES;
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
#pragma mark Selectors

- (void)cancelButtonDidTouchUpInside
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
	[emailInput resignFirstResponder];
	[passwordInput resignFirstResponder];
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
