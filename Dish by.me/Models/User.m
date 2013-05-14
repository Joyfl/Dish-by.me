//
//  User.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "User.h"

@implementation User

+ (id)userFromDictionary:(NSDictionary *)dictionary
{
	User *user = [[User alloc] init];
	user.userId = [[dictionary objectForKeyNotNull:@"id"] integerValue];
	user.name = [dictionary objectForKeyNotNull:@"name"];
	user.photoURL = [dictionary objectForKeyNotNull:@"photo_url"];
	user.thumbnailURL = [dictionary objectForKeyNotNull:@"thumbnail_url"];
	user.bio = [dictionary objectForKeyNotNull:@"bio"];
	user.dishCount = [[dictionary objectForKeyNotNull:@"dish_count"] integerValue];
	user.bookmarkCount = [[dictionary objectForKeyNotNull:@"bookmark_count"] integerValue];
	user.followingCount = [[dictionary objectForKeyNotNull:@"following_count"] integerValue];
	user.followersCount = [[dictionary objectForKeyNotNull:@"followers_count"] integerValue];
	user.following = [[dictionary objectForKeyNotNull:@"following"] boolValue];
	user.activated = [[dictionary objectForKeyNotNull:@"activated"] boolValue];
	return user;
}

- (id)dictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInteger:self.userId], @"id",
			self.name, @"name",
			self.photoURL, @"photo_url",
			self.thumbnailURL, @"thumbnail_url",
			self.bio, @"bio",
			[NSNumber numberWithInteger:self.dishCount], @"dish_count",
			[NSNumber numberWithInteger:self.bookmarkCount], @"bookmark_count",
			[NSNumber numberWithInteger:self.followingCount], @"following_count",
			[NSNumber numberWithInteger:self.followersCount], @"followers_count",
			nil];
}

@end
