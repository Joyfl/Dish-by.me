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
	_ingredients = [NSMutableArray array];
	_contents = [NSMutableArray array];
	
	for( int i = 0; i < 10; i++ )
	{
		Ingredient *ingredient = [[Ingredient alloc] init];
		ingredient.name = [NSString stringWithFormat:@"ingredient %d\n", i];
		ingredient.amount = [NSString stringWithFormat:@"amount %d\n", i];
		[_ingredients addObject:ingredient];
		
		RecipeContent *content = [[RecipeContent alloc] init];
		content.photo = nil;
		content.content = [NSString stringWithFormat:@"content %d\n", i];
		[_contents addObject:content];
	}
	
	return self;
}

@end
