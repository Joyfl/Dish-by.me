//
//  Dish.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "Dish.h"
#import "Recipe.h"

@implementation Dish

@synthesize dishId, dishName, userId, userName, userPhotoURL, userPhoto, description, recipe, photoURL, photo, thumbnailURL, thumbnail, forkedFromId, forkedFromName, forkCount, bookmarkCount, commentCount, bookmarked, createdTime, relativeCreatedTime, updatedTime, relativeUpdatedTime;

+ (id)dishFromDictionary:(NSDictionary *)dictionary
{
	Dish *dish = [[Dish alloc] init];
	dish.dishId = [[dictionary objectForKey:@"id"] integerValue];
	dish.dishName = [dictionary objectForKey:@"name"];
	dish.userId = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] integerValue];
	dish.userName = [[dictionary objectForKey:@"user"] objectForKey:@"name"];
	dish.userPhotoURL = [[dictionary objectForKey:@"user"] objectForKey:@"photo_url"];
	dish.description = [dictionary objectForKey:@"description"];
	dish.recipe = [Recipe recipeFromDictionary:[dictionary objectForKey:@"recipe"]];
	dish.photoWidth = [[dictionary objectForKey:@"photo_width"] integerValue];
	dish.photoHeight = [[dictionary objectForKey:@"photo_height"] integerValue];
	dish.photoURL = [dictionary objectForKey:@"photo_url"];
	dish.thumbnailURL = [dictionary objectForKey:@"thumbnail_url"];
	dish.forkedFromId = [[[dictionary objectForKey:@"forked_from"] objectForKey:@"id"] integerValue];
	dish.forkedFromName = [[dictionary objectForKey:@"forked_from"] objectForKey:@"name"];
	dish.forkCount = [[dictionary objectForKey:@"fork_count"] integerValue];
	dish.bookmarkCount = [[dictionary objectForKey:@"bookmark_count"] integerValue];
	dish.commentCount = [[dictionary objectForKey:@"comment_count"] integerValue];
	dish.bookmarked = [[dictionary objectForKey:@"bookmarked"] boolValue];
	dish.createdTime = [Utils dateFromString:[dictionary objectForKey:@"created_time"]];
	dish.updatedTime = [Utils dateFromString:[dictionary objectForKey:@"updated_time"]];
	[dish updateRelativeTime];
	
	return dish;
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
	self.relativeUpdatedTime = [Utils relativeDateString:self.updatedTime withTime:YES];
}

@end
