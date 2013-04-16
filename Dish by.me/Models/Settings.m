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
	_name = [dictionary objectForKey:@"name"];
	_og = [[dictionary objectForKey:@"og"] boolValue];
	return self;
}

@end



@implementation NotificationSettings

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	_follow = [[dictionary objectForKey:@"follow"] boolValue];
	_bookmark = [[dictionary objectForKey:@"bookmark"] boolValue];
	_comment = [[dictionary objectForKey:@"comment"] boolValue];
	_fork = [[dictionary objectForKey:@"fork"] boolValue];
	return self;
}

@end



@implementation Settings

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	self.facebook = [dictionary objectForKey:@"facebook"] ? [[FacebookSettings alloc] initWithDictionary:[dictionary objectForKey:@"facebook"]] : nil;
	self.notifications = [[NotificationSettings alloc] initWithDictionary:[dictionary objectForKey:@"notifications"]];
	return self;
}

@end
