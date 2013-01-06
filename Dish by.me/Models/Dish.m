//
//  Dish.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "Dish.h"
#import "Const.h"

@implementation Dish

@synthesize dishId, dishName, userId, userName, userThumbnailURL, userThumbnail, description, recipe, photoURL, photo, thumbnailURL, thumbnail, forkedFromId, forkedFromName, forkCount, bookmarkCount, commentCount, createdTime, updatedTime;

+ (id)dishFromDictionary:(NSDictionary *)dictionary
{
	Dish *dish = [[Dish alloc] init];
	dish.dishId = [[dictionary objectForKey:@"id"] integerValue];
	dish.dishName = [dictionary objectForKey:@"name"];
	dish.userId = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] integerValue];
	dish.userName = [[dictionary objectForKey:@"user"] objectForKey:@"name"];
	dish.userThumbnailURL = [[dictionary objectForKey:@"user"] objectForKey:@"thumbnail_url"];
	dish.description = [dictionary objectForKey:@"description"];
	dish.recipe = [dictionary objectForKey:@"recipe"];
	dish.photoURL = [dictionary objectForKey:@"photo_url"];
	dish.thumbnailURL = [dictionary objectForKey:@"thumbnail_url"];
	dish.forkedFromId = [[[dictionary objectForKey:@"forked_from"] objectForKey:@"id"] integerValue];
	dish.forkedFromName = [[dictionary objectForKey:@"forked_from"] objectForKey:@"name"];
	dish.forkCount = [[dictionary objectForKey:@"forkCount"] integerValue];
	dish.bookmarkCount = [[dictionary objectForKey:@"bookmarkCount"] integerValue];
	dish.commentCount = [[dictionary objectForKey:@"commentCount"] integerValue];
	dish.createdTime = [dictionary objectForKey:@"createdTime"];
	dish.updatedTime = [dictionary objectForKey:@"updatedTime"];
	return dish;
}

@end
