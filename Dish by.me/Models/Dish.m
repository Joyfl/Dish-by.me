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

@synthesize dishId, dishName, userId, userName, message, forkedFrom, forkedFromName, forkCount, time, hasRecipe, recipe, yumCount, commentCount, photo, thumbnail;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [[Dish alloc] init];
	self.dishId = [[dictionary objectForKey:@"dish_id"] integerValue];
	self.dishName = [dictionary objectForKey:@"dish_name"];
	self.userId = [[dictionary objectForKey:@"user_id"] integerValue];
	self.userName = [dictionary objectForKey:@"user_name"];
	self.message = [dictionary objectForKey:@"message"];
	self.forkedFrom = [[dictionary objectForKey:@"forked_from"] integerValue];
//	self.time = [dictionary objectForKey:@"dish_id"];
	self.hasRecipe = [[dictionary objectForKey:@"has_recipe"] boolValue];
	if( self.hasRecipe )
		self.recipe = [dictionary objectForKey:@"recipe"];
	self.yumCount = [[dictionary objectForKey:@"yum_count"] integerValue];
	self.commentCount = [[dictionary objectForKey:@"comment_count"] integerValue];
	
	return self;
}

@end
