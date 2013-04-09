//
//  Ingredient.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

+ (id)ingredientFromDictionary:(NSDictionary *)dictionary
{
	Ingredient *ingredient = [[Ingredient alloc] init];
	ingredient.name = [dictionary objectForKey:@"name"];
	ingredient.amount = [dictionary objectForKey:@"amount"];
	return ingredient;
}

@end
