//
//  RecipeContent.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeContent.h"

@implementation RecipeContent

+ (id)recipeContentFromDictionary:(NSDictionary *)dictionary
{
	RecipeContent *content = [[RecipeContent alloc] init];
	content.photoURL = [dictionary objectForKey:@"photo_url"];
	content.description = [dictionary objectForKey:@"description"];
	return content;
}

@end
