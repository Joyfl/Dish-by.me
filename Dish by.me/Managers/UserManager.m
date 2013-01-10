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

+ (UserManager *)manager
{
	static UserManager *manager = nil;
	if( !manager )
		manager = [[UserManager alloc] init];
	return manager;
}

- (void)logout
{
	[[SettingsManager manager] clearSettingForKey:SETTING_KEY_LOGGED_IN];
	[[SettingsManager manager] clearSettingForKey:SETTING_KEY_ACCESS_TOKEN];
	[[SettingsManager manager] clearSettingForKey:SETTING_KEY_USER_ID];
	[[SettingsManager manager] clearSettingForKey:SETTING_KEY_USER_NAME];
	[[SettingsManager manager] flush];
}

#pragma mark -
#pragma mark Getter/Setter

- (BOOL)loggedIn
{
	return [[[SettingsManager manager] getSettingForKey:SETTING_KEY_LOGGED_IN] boolValue];
}

- (void)setLoggedIn:(BOOL)loggedIn
{
	[[SettingsManager manager] setSetting:[NSNumber numberWithBool:loggedIn] forKey:SETTING_KEY_LOGGED_IN];
	[[SettingsManager manager] flush];
}


- (NSString *)accessToken
{
	return [[SettingsManager manager] getSettingForKey:SETTING_KEY_ACCESS_TOKEN];
}

- (void)setAccessToken:(NSString *)accessToken
{
	[[SettingsManager manager] setSetting:accessToken forKey:SETTING_KEY_ACCESS_TOKEN];
	[[SettingsManager manager] flush];
}


- (NSInteger)userId
{
	return [[[SettingsManager manager] getSettingForKey:SETTING_KEY_USER_ID] integerValue];
}

- (void)setUserId:(NSInteger)userId
{
	[[SettingsManager manager] setSetting:[NSNumber numberWithInteger:userId] forKey:SETTING_KEY_USER_ID];
	[[SettingsManager manager] flush];
}


- (NSString *)userName
{
	return [[SettingsManager manager] getSettingForKey:SETTING_KEY_USER_NAME];
}

- (void)setUserName:(NSString *)userName
{
	[[SettingsManager manager] setSetting:userName forKey:SETTING_KEY_USER_NAME];
	[[SettingsManager manager] flush];
}


- (UIImage *)userPhoto
{
	if( !_userPhoto )
		_userPhoto = [[UIImage imageWithContentsOfFile:[(NSString *)[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"UserPhoto.png"]] retain];
	return _userPhoto;
}

- (void)setUserPhoto:(UIImage *)userPhoto
{
	[UIImagePNGRepresentation( _userPhoto = [userPhoto retain] ) writeToFile:[[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"UserPhoto.png"] atomically:YES];
}

@end
