//
//  User.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userId, name, photoURL, photo, thumbnailURL, thumbnail, bio, dishCount, bookmarkCount, followingCount, followersCount;

+ (id)userFromDictionary:(NSDictionary *)dictionary
{
	User *user = [[User alloc] init];
	user.userId = [[dictionary objectForKey:@"id"] integerValue];
	user.name = [dictionary objectForKey:@"name"];
	user.photoURL = [dictionary objectForKey:@"photo_url"];
	user.thumbnailURL = [dictionary objectForKey:@"thumbnail_url"];
	user.bio = [dictionary objectForKey:@"bio"];
	user.dishCount = [[dictionary objectForKey:@"dish_count"] integerValue];
	user.bookmarkCount = [[dictionary objectForKey:@"bookmark_count"] integerValue];
	user.followingCount = [[dictionary objectForKey:@"following_count"] integerValue];
	user.followersCount = [[dictionary objectForKey:@"followers_count"] integerValue];
	user.following = [[dictionary objectForKey:@"following"] boolValue];
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
