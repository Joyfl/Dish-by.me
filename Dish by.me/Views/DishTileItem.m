//
//  DishTileItem.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileItem.h"

@implementation DishTileItem

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	_photoButton = [[UIButton alloc] initWithFrame:CGRectMake( 4, 4, 88, 88 )];
	[_photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_photoButton];
	
	_borderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_tile_border.png"]];
	[self addSubview:_borderView];
	
	return self;
}

- (void)setDish:(Dish *)dish
{
	_dish = dish;
	
	if( _dish.croppedThumbnail )
	{
		[_photoButton setBackgroundImage:_dish.croppedThumbnail forState:UIControlStateNormal];
	}
	else
	{
		[_photoButton setBackgroundImageWithURL:[NSURL URLWithString:_dish.thumbnailURL] placeholderImage:[UIImage imageNamed:@"dish_tile_loading.png"] forState:UIControlStateNormal success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_dish.croppedThumbnail = [Utils cropImageToSquare:image];
			[_photoButton setBackgroundImage:_dish.croppedThumbnail forState:UIControlStateNormal];
		} failure:nil];
	}
}

- (void)photoButtonDidTouchUpInside
{
	[self.delegate dishTileItemDidTouchUpInside:self];
}

@end
