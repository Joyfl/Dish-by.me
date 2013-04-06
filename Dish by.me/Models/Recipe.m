//
//  Recipe.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Recipe.h"

@implementation Recipe

- (id)init
{
	self = [super init];
	self.ingredients = [NSMutableArray array];
	self.contents = [NSMutableArray array];
	
	for( int i = 0; i < 3; i++ )
	{
		Ingredient *ingredient = [[Ingredient alloc] init];
		ingredient.name = [NSString stringWithFormat:@"ingredient %d", i];
		ingredient.amount = [NSString stringWithFormat:@"amount %d", i];
		[_ingredients addObject:ingredient];
		
		RecipeContent *content = [[RecipeContent alloc] init];
		content.photo = nil;
		content.content = [NSString stringWithFormat:@"content %d", i];
		[_contents addObject:content];
	}
	
	return self;
}

@end
