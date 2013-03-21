//
//  SignUpViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController

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
	
	_signUpButton = [[DMBookButton alloc] initWithPosition:CGPointMake( 30, UIScreenHeight - 195 ) title:NSLocalizedString( @"SIGNUP", nil )];
	[_signUpButton addTarget:self action:@selector(signUpButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_signUpButton];
	
	_loginButton = [[DMBookButton alloc] initWithPosition:CGPointMake( 30, UIScreenHeight - 145 ) title:NSLocalizedString( @"LOGIN", nil )];
	[_loginButton addTarget:self action:@selector(loginButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_loginButton];
	
	_lookAroundButton = [[DMBookButton alloc] initWithPosition:CGPointMake( 30, UIScreenHeight - 95 ) title:NSLocalizedString( @"LOOK_AROUND", nil )];
	[_lookAroundButton addTarget:self action:@selector(lookAroundButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_lookAroundButton];
	
	return self;
}

@end
