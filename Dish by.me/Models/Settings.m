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

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	self.facebook = [dictionary objectForKeyNotNull:@"facebook"] ? [[FacebookSettings alloc] initWithDictionary:[dictionary objectForKeyNotNull:@"facebook"]] : nil;
	self.notifications = [[NotificationSettings alloc] initWithDictionary:[dictionary objectForKeyNotNull:@"notifications"]];
	return self;
}

@end
