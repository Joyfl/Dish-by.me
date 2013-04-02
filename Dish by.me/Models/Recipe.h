//
//  Recipe.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ingredient.h"
#import "RecipeContent.h"

@interface Recipe : NSObject

@property (nonatomic, assign) NSInteger servings;
@property (nonatomic, assign) NSInteger minutes;
@property (nonatomic, assign) NSMutableArray *ingredients;
@property (nonatomic, assign) NSMutableArray *contents;

@end