//
//  DishTileItem.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileItem.h"
#import "Const.h"

@implementation DishTileItem

@synthesize dish;

- (id)init
{
	self = [super init];
	self.imageEdgeInsets = UIEdgeInsetsMake( -4, -4, -4, -4 );
	[self setBackgroundImage:[UIImage imageNamed:@"dish_tile_loading.png"] forState:UIControlStateNormal];
	
	return self;
}

- (void)setDish:(Dish *)_dish
{
	dish = _dish;
	[self setImage:[UIImage imageNamed:dish.recipe ? @"dish_tile_border_ribbon.png" : @"dish_tile_border.png"] forState:UIControlStateNormal];
	
	if( dish.photo )
	{
		[self setBackgroundImage:dish.photo forState:UIControlStateNormal];
	}
	else
	{
		[self loadPhoto];
	}
}

- (void)loadThumbnail
{
	dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
		NSString *rootURL = WEB_ROOT_URL;
		NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/thumbnail/dish/%d", rootURL, dish.dishId]]];
		if( data == nil )
			return;
		
		dispatch_async( dispatch_get_main_queue(), ^{
			dish.photo = [UIImage imageWithData: data];
		} );
	});
}

- (void)loadPhoto
{
	dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
		NSString *rootURL = WEB_ROOT_URL;
		NSString *url = [NSString stringWithFormat:@"%@/images/original/dish/%d_%d.jpg", rootURL, dish.dishId, dish.userId];
		NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
		if( data == nil )
			return;
		
		dispatch_async( dispatch_get_main_queue(), ^{
			dish.photo = [UIImage imageWithData:data];
			[self setBackgroundImage:dish.photo forState:UIControlStateNormal];
		} );
	});
}

@end
