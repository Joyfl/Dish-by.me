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
	[dish updateFromDictionary:dictionary];
	return dish;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
	self.dishId = [[dictionary objectForKeyNotNull:@"id"] integerValue];
	self.dishName = [dictionary objectForKeyNotNull:@"name"];
	self.userId = [[[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"id"] integerValue];
	self.userName = [[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"name"];
	self.userPhotoURL = [[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"photo_url"];
	self.description = [dictionary objectForKeyNotNull:@"description"];
	self.recipe = [[dictionary objectForKeyNotNull:@"recipe"] count] > 0 ? [Recipe recipeFromDictionary:[dictionary objectForKeyNotNull:@"recipe"]] : nil;
	self.photoWidth = [[dictionary objectForKeyNotNull:@"photo_width"] integerValue];
	self.photoHeight = [[dictionary objectForKeyNotNull:@"photo_height"] integerValue];
	self.photoURL = [dictionary objectForKeyNotNull:@"photo_url"];
	self.thumbnailURL = [dictionary objectForKeyNotNull:@"thumbnail_url"];
	self.forkedFromId = [[[dictionary objectForKeyNotNull:@"forked_from"] objectForKeyNotNull:@"id"] integerValue];
	self.forkedFromName = [[dictionary objectForKeyNotNull:@"forked_from"] objectForKeyNotNull:@"name"];
	self.forkCount = [[dictionary objectForKeyNotNull:@"fork_count"] integerValue];
	self.bookmarkCount = [[dictionary objectForKeyNotNull:@"bookmark_count"] integerValue];
	self.commentCount = [[dictionary objectForKeyNotNull:@"comment_count"] integerValue];
	self.bookmarked = [[dictionary objectForKeyNotNull:@"bookmarked"] boolValue];
	self.createdTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"created_time"]];
	self.updatedTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"updated_time"]];
	[self updateRelativeTime];
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
	self.relativeUpdatedTime = [Utils relativeDateString:self.updatedTime withTime:YES];
}

@end
