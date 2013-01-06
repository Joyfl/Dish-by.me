//
//  UserManager.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "UserManager.h"
#import "SettingsManager.h"
#import "Const.h"

@implementation UserManager

@synthesize loggedIn, user;

+ (UserManager *)manager
{
	static UserManager *manager = nil;
	if( !manager )
		manager = [[UserManager alloc] init];
	return manager;
}


#pragma mark -
#pragma mark Getter/Setter

- (NSString *)accessToken
{
	return _accessToken;
}

- (void)setAccessToken:(NSString *)accessToken
{
	[[SettingsManager manager] setSetting:_accessToken = accessToken forKey:SETTING_KEY_ACCESS_TOKEN];
	[[SettingsManager manager] flush];
}

@end
