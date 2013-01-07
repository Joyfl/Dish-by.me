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


#pragma mark -
#pragma mark Getter/Setter

- (BOOL)loggedIn
{
	static NSNumber *loggedIn = nil;
	if( !loggedIn )
		loggedIn = [[SettingsManager manager] getSettingForKey:SETTING_KEY_LOGGED_IN];
	return [loggedIn boolValue];
}

- (void)setLoggedIn:(BOOL)loggedIn
{
	[[SettingsManager manager] setSetting:[NSNumber numberWithBool:loggedIn] forKey:SETTING_KEY_LOGGED_IN];
	[[SettingsManager manager] flush];
}


- (NSString *)accessToken
{
	static NSString *accessToken = nil;
	if( !accessToken )
		accessToken = [[SettingsManager manager] getSettingForKey:SETTING_KEY_ACCESS_TOKEN];
	return accessToken;
}

- (void)setAccessToken:(NSString *)accessToken
{
	[[SettingsManager manager] setSetting:accessToken forKey:SETTING_KEY_ACCESS_TOKEN];
	[[SettingsManager manager] flush];
}


- (NSInteger)userId
{
	static NSNumber *userId = nil;
	if( !userId )
		userId = [[SettingsManager manager] getSettingForKey:SETTING_KEY_USER_ID];
	return [userId integerValue];
}

- (void)setUserId:(NSInteger)userId
{
	[[SettingsManager manager] setSetting:[NSNumber numberWithInteger:userId] forKey:SETTING_KEY_USER_ID];
	[[SettingsManager manager] flush];
}


- (NSString *)userName
{
	static NSString *userName = nil;
	if( !userName )
		userName = [[SettingsManager manager] getSettingForKey:SETTING_KEY_USER_NAME];
	return userName;
}

- (void)setUserName:(NSString *)userName
{
	[[SettingsManager manager] setSetting:userName forKey:SETTING_KEY_USER_NAME];
	[[SettingsManager manager] flush];
}


- (UIImage *)userPhoto
{
	static UIImage *userPhoto = nil;
	if( !userPhoto )
		userPhoto = [UIImage imageWithContentsOfFile:[(NSString *)[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"UserPhoto.png"]];
	return userPhoto;
}

- (void)setUserPhoto:(UIImage *)userPhoto
{
	[UIImagePNGRepresentation( userPhoto ) writeToFile:[[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"UserPhoto.png"] atomically:YES];
}

@end
