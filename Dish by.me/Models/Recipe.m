//
//  Recipe.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Recipe.h"
#import "Ingredient.h"
#import "RecipeContent.h"

@implementation Recipe

+ (id)recipeFromDictionary:(NSDictionary *)dictionary
{
	Recipe *recipe = [[Recipe alloc] init];
	recipe.servings = [[dictionary objectForKeyNotNull:@"servings"] integerValue];
	recipe.minutes = [[dictionary objectForKeyNotNull:@"minutes"] integerValue];
	
	NSArray *ingredients = [dictionary objectForKeyNotNull:@"ingredients"];
	for( NSDictionary *ingredientDictionary in ingredients )
	{
		Ingredient *ingredient = [Ingredient ingredientFromDictionary:ingredientDictionary];
		[recipe.ingredients addObject:ingredient];
	}
	
	NSArray *contents = [dictionary objectForKeyNotNull:@"contents"];
	for( NSDictionary *contentDictionary in contents )
	{
		RecipeContent *content = [RecipeContent recipeContentFromDictionary:contentDictionary];
		[recipe.contents addObject:content];
	}
	
	return recipe;
}

- (id)init
{
	self = [super init];
	self.ingredients = [NSMutableArray array];
	self.contents = [NSMutableArray array];
//	for( int i = 0; i < 3; i ++ )
//	{
//		RecipeContent *content = [[RecipeContent alloc] init];
//		content.description = [NSString stringWithFormat:@"Description %d", i];
//		[self.contents addObject:content];
//	}
	return self;
}

@end
