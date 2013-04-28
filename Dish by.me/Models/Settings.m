//
//  Setting.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 17..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Settings.h"

@implementation FacebookSettings

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	_name = [dictionary objectForKeyNotNull:@"name"];
	_og = [[dictionary objectForKeyNotNull:@"og"] boolValue];
	return self;
}

@end



@implementation NotificationSettings

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	_follow = [[dictionary objectForKeyNotNull:@"follow"] boolValue];
	_bookmark = [[dictionary objectForKeyNotNull:@"bookmark"] boolValue];
	_comment = [[dictionary objectForKeyNotNull:@"comment"] boolValue];
	_fork = [[dictionary objectForKeyNotNull:@"fork"] boolValue];
	return self;
}

@end



@implementation Settings

+ (id)sharedSettings
{
	static Settings *settings = nil;
	if( !settings )
	{
		settings = [[Settings alloc] init];
	}
	return settings;
}

- (id)init
{
	self = [super init];
	self.facebook = [[FacebookSettings alloc] init];
	self.notifications = [[NotificationSettings alloc] init];
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	[self updateFromDictionary:dictionary];
	return self;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
	self.facebook = [dictionary objectForKeyNotNull:@"facebook"] ? [[FacebookSettings alloc] initWithDictionary:[dictionary objectForKeyNotNull:@"facebook"]] : nil;
	self.notifications = [[NotificationSettings alloc] initWithDictionary:[dictionary objectForKeyNotNull:@"notifications"]];
}

- (void)loadSettings
{
	
}

@end
