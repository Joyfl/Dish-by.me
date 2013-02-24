//
//  UserManager.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager

+ (UserManager *)manager
{
	static UserManager *manager = nil;
	if( !manager )
	{
		manager = [[UserManager alloc] init];
	}
	return manager;
}

- (id)init
{
	self = [super init];
	_userDefaults = [NSUserDefaults standardUserDefaults];
	return self;
}

- (void)logout
{
	[_userDefaults removeObjectForKey:SETTING_KEY_LOGGED_IN];
	[_userDefaults removeObjectForKey:SETTING_KEY_ACCESS_TOKEN];
	[_userDefaults removeObjectForKey:SETTING_KEY_USER_ID];
	[_userDefaults removeObjectForKey:SETTING_KEY_USER_NAME];
	[_userDefaults synchronize];
}

#pragma mark -
#pragma mark Getter/Setter

- (BOOL)loggedIn
{
	return [_userDefaults boolForKey:SETTING_KEY_LOGGED_IN];
}

- (void)setLoggedIn:(BOOL)loggedIn
{
	[_userDefaults setBool:loggedIn forKey:SETTING_KEY_LOGGED_IN];
	[_userDefaults synchronize];
}


- (NSString *)accessToken
{
	return [_userDefaults stringForKey:SETTING_KEY_ACCESS_TOKEN];
}

- (void)setAccessToken:(NSString *)accessToken
{
	[_userDefaults setObject:accessToken forKey:SETTING_KEY_ACCESS_TOKEN];
	[_userDefaults synchronize];
}


- (NSInteger)userId
{
	return [_userDefaults integerForKey:SETTING_KEY_USER_ID];
}

- (void)setUserId:(NSInteger)userId
{
	[_userDefaults setInteger:userId forKey:SETTING_KEY_USER_ID];
	[_userDefaults synchronize];
}


- (NSString *)userName
{
	return [_userDefaults stringForKey:SETTING_KEY_USER_NAME];
}

- (void)setUserName:(NSString *)userName
{
	[_userDefaults setObject:userName forKey:SETTING_KEY_USER_NAME];
	[_userDefaults synchronize];
}


- (UIImage *)userPhoto
{
	if( !_userPhoto )
		_userPhoto = [UIImage imageWithContentsOfFile:[(NSString *)[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"UserPhoto.png"]];
	return _userPhoto;
}

- (void)setUserPhoto:(UIImage *)userPhoto
{
	[UIImagePNGRepresentation( _userPhoto = userPhoto ) writeToFile:[[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"UserPhoto.png"] atomically:YES];
}

@end
