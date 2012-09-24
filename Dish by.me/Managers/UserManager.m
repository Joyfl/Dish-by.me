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

+ (BOOL)loggedIn
{
	NSString *key = SETTING_KEY_USER_ID;
	return [[SettingsManager manager] getSettingForKey:key] != nil;
}

+ (NSInteger)userId
{
	NSString *key = SETTING_KEY_USER_ID;
	return [[[SettingsManager manager] getSettingForKey:key] integerValue];
}

+ (NSNumber *)userIdNumber
{
	NSString *key = SETTING_KEY_USER_ID;
	return [[SettingsManager manager] getSettingForKey:key];
}

+ (NSString *)userName
{
	NSString *key = SETTING_KEY_USER_NAME;
	return [[SettingsManager manager] getSettingForKey:key];
}

+ (NSString *)email
{
	NSString *key = SETTING_KEY_EMAIL;
	return [[SettingsManager manager] getSettingForKey:key];
}

// hashed password
+ (NSString *)password
{
	NSString *key = SETTING_KEY_PASSWORD;
	return [[SettingsManager manager] getSettingForKey:key];
}

+ (void)logout
{
	NSString *key = SETTING_KEY_USER_ID;
	[[SettingsManager manager] clearSettingForKey:key];
	
	key = SETTING_KEY_USER_NAME;
	[[SettingsManager manager] clearSettingForKey:key];
	
	key = SETTING_KEY_EMAIL;
	[[SettingsManager manager] clearSettingForKey:key];
	
	key = SETTING_KEY_PASSWORD;
	[[SettingsManager manager] clearSettingForKey:key];
	
	[[SettingsManager manager] flush];
}

@end
