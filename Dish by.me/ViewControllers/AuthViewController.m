//
//  FirstViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "AuthViewController.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DMBookButton.h"
#import "UIResponder+Dim.h"
#import "CurrentUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DMNavigationController.h"

@implementation AuthViewController

- (id)init
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	bgView.image = [UIImage imageNamed:@"book_background.png"];
	[self.view addSubview:bgView];
	
	UIImageView *paperView = [[UIImageView alloc] initWithFrame:CGRectMake( 7, 7, 305, UIScreenHeight - 35 )];
	paperView.image = [UIImage imageNamed:@"book_paper.png"];
	[self.view addSubview:paperView];
	
	UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake( 135, 124, 50, 55 )];
	logoView.image = [UIImage imageNamed:@"icon_logo.png"];
	[self.view addSubview:logoView];
	
	DMBookButton *signUpButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, UIScreenHeight - 195 ) title:NSLocalizedString( @"SIGNUP", nil )];
	[signUpButton addTarget:self action:@selector(signUpButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:signUpButton];
	
	DMBookButton *loginButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, UIScreenHeight - 145 ) title:NSLocalizedString( @"LOGIN", nil )];
	[loginButton addTarget:self action:@selector(loginButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:loginButton];
	
	DMBookButton *lookAroundButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, UIScreenHeight - 95 ) title:NSLocalizedString( @"LOOK_AROUND", nil )];
	[lookAroundButton addTarget:self action:@selector(lookAroundButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:lookAroundButton];
	
	return self;
}


#pragma mark -

- (void)presentWithoutClosingCoverFromViewController:(UIViewController *)viewController delegate:(id<AuthViewControllerDelegate>)delegate
{
	DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:self];
	navController.navigationBarHidden = YES;
	
	[viewController presentViewController:navController animated:NO completion:nil];
	[self openBookCover];
}

- (void)presentFromViewController:(UIViewController *)viewController delegate:(id<AuthViewControllerDelegate>)delegate
{
	DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:self];
	navController.navigationBarHidden = YES;
	
	[self closeBookCoverCompletion:^(UIImageView *coverView) {
		[viewController presentViewController:navController animated:NO completion:nil];
		[coverView removeFromSuperview];
		[self openBookCover];
	}];
}


#pragma mark -

- (void)signUpButtonDidTouchUpInside
{
	SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
	[self.navigationController pushViewController:signUpViewController animated:YES];
}

- (void)loginButtonDidTouchUpInside
{
	LoginViewController *loginViewController = [[LoginViewController alloc] init];
	[self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)lookAroundButtonDidTouchUpInside
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getUser
{
	[self dim];
	
	JLLog( @"getUser" );
	[[DMAPILoader sharedLoader] api:@"/user" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"getUser success" );
		
		[self undim];
		
		[[CurrentUser user] updateToDictionary:response];
		[[CurrentUser user] save];
		
		AuthViewController *authViewController = [self.navigationController.viewControllers objectAtIndex:0];
		[authViewController.delegate authViewControllerDidSucceedLogin:authViewController];
		
		[[FBSession activeSession] closeAndClearTokenInformation];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self undim];
		showErrorAlert();
	}];
}

- (void)openBookCover
{
	[self openBookCoverAfterDelay:0.5];
}

- (void)openBookCoverAfterDelay:(NSTimeInterval)delay
{
	UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	coverView.image = [UIImage imageNamed:UIScreenHeight == 480 ? @"Default.png" : @"Default-568h.png"];
	[[[UIApplication sharedApplication] keyWindow] addSubview:coverView];
	[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:coverView];
	
	coverView.layer.anchorPoint = CGPointMake( 0, 0.5 );
	coverView.center = CGPointMake( 0, 20 + coverView.frame.size.height / 2 );
	coverView.transform = CGAffineTransformMakeTranslation( 0, 0 );
	CATransform3D transform = CATransform3DIdentity;
	
	transform = CATransform3DMakeRotation( M_PI_2, 0, -1, 0 );
	transform.m34 = 0.001f;
	transform.m14 = -0.0015f;
	
	[UIView animateWithDuration:1 delay:delay options:0 animations:^{
		coverView.layer.transform = transform;
		
	} completion:^(BOOL finished) {
		[coverView removeFromSuperview];
	}];
}

- (void)closeBookCoverCompletion:(void (^)(UIImageView *coverView))completion
{
	UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	coverView.image = [UIImage imageNamed:UIScreenHeight == 480 ? @"Default.png" : @"Default-568h.png"];
	[[[UIApplication sharedApplication] keyWindow] addSubview:coverView];
	[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:coverView];
	
	coverView.layer.anchorPoint = CGPointMake( 0, 0.5 );
	coverView.center = CGPointMake( 0, 20 + coverView.frame.size.height / 2 );
	coverView.transform = CGAffineTransformMakeTranslation( 0, 0 );
	
	CATransform3D transform = CATransform3DIdentity;
	transform = CATransform3DMakeRotation( M_PI_2, 0, -1, 0 );
	transform.m34 = 0.001f;
	transform.m14 = -0.0015f;
	coverView.layer.transform = transform;
	
	transform = CATransform3DMakeRotation( M_PI_2, 0, 0, 0 );
	
	[UIView animateWithDuration:1 animations:^{
		coverView.layer.transform = transform;
		
	} completion:^(BOOL finished) {
		if( completion ) completion( coverView );
	}];
}

@end
