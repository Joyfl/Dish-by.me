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

@end
