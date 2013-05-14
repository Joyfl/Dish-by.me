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

+ (id)dishFromDictionary:(NSDictionary *)dictionary
{
	Dish *dish = [[Dish alloc] init];
	dish.dishId = [[dictionary objectForKeyNotNull:@"id"] integerValue];
	dish.dishName = [dictionary objectForKeyNotNull:@"name"];
	dish.userId = [[[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"id"] integerValue];
	dish.userName = [[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"name"];
	dish.userPhotoURL = [[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"photo_url"];
	dish.description = [dictionary objectForKeyNotNull:@"description"];
	dish.recipe = [[dictionary objectForKeyNotNull:@"recipe"] count] > 0 ? [Recipe recipeFromDictionary:[dictionary objectForKeyNotNull:@"recipe"]] : nil;
	dish.photoWidth = [[dictionary objectForKeyNotNull:@"photo_width"] integerValue];
	dish.photoHeight = [[dictionary objectForKeyNotNull:@"photo_height"] integerValue];
	dish.photoURL = [dictionary objectForKeyNotNull:@"photo_url"];
	dish.thumbnailURL = [dictionary objectForKeyNotNull:@"thumbnail_url"];
	dish.forkedFromId = [[[dictionary objectForKeyNotNull:@"forked_from"] objectForKeyNotNull:@"id"] integerValue];
	dish.forkedFromName = [[dictionary objectForKeyNotNull:@"forked_from"] objectForKeyNotNull:@"name"];
	dish.forkCount = [[dictionary objectForKeyNotNull:@"fork_count"] integerValue];
	dish.bookmarkCount = [[dictionary objectForKeyNotNull:@"bookmark_count"] integerValue];
	dish.commentCount = [[dictionary objectForKeyNotNull:@"comment_count"] integerValue];
	dish.bookmarked = [[dictionary objectForKeyNotNull:@"bookmarked"] boolValue];
	dish.createdTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"created_time"]];
	dish.updatedTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"updated_time"]];
	[dish updateRelativeTime];
	
	return dish;
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
	self.relativeUpdatedTime = [Utils relativeDateString:self.updatedTime withTime:YES];
}

@end
