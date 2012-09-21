//
//  DishTileItem.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileItem.h"

@implementation DishTileItem

@synthesize dish;

- (id)initWithDish:(Dish *)_dish
{
	self = [super init];
	
	dish = _dish;
	
	return self;
}

@end
