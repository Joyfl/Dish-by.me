//
//  SettingsViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserManager.h"

@implementation SettingsViewController

- (id)init
{
    self = [super init];
	
	
	
    return self;
}

#warning 임시 로그아웃 코드
- (void)viewWillAppear:(BOOL)animated
{
	if( [UserManager manager].loggedIn )
	{
		[[UserManager manager] logout];
		[[[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString( @"LOGOUT_SUCCEED", @"로그아웃되었습니다." ) delegate:nil cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"알겠어요" ) otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		[[[[UIAlertView alloc] initWithTitle:@"" message:@"로그인되어있지 않습니다." delegate:nil cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"알겠어요" ) otherButtonTitles:nil] autorelease] show];
	}
}

@end
