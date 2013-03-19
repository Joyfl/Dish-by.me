//
//  DishTileItem.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileItem.h"
#import "JLHTTPLoader.h"

@implementation DishTileItem

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	_photoButton = [[UIButton alloc] initWithFrame:CGRectMake( 4, 4, 88, 88 )];
	[_photoButton setBackgroundImage:[UIImage imageNamed:@"dish_tile_loading.png"] forState:UIControlStateNormal];
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
		[JLHTTPLoader loadAsyncFromURL:_dish.thumbnailURL withObject:nil completion:^(id object, NSData *data){
			UIImage *thumbnail = [UIImage imageWithData:data];
			_dish.thumbnail = thumbnail;
			
			// Square
			if( thumbnail.size.width == thumbnail.size.height )
			{
				_dish.croppedThumbnail = thumbnail;
			}
			
			// Landscape
			else if( thumbnail.size.width > thumbnail.size.height )
			{
				CGRect rect = CGRectMake( ( thumbnail.size.width - thumbnail.size.height ) / 2, 0, thumbnail.size.height, thumbnail.size.height );
				_dish.croppedThumbnail = [Utils cropImage:thumbnail toRect:rect];
			}
			
			// Portrait
			else
			{
				CGRect rect = CGRectMake( 0, ( thumbnail.size.height - thumbnail.size.width ) / 2, thumbnail.size.width, thumbnail.size.width );
				_dish.croppedThumbnail = [Utils cropImage:thumbnail toRect:rect];
			}
			
			[_photoButton setBackgroundImage:_dish.croppedThumbnail forState:UIControlStateNormal];
		}];
	}
}

- (void)photoButtonDidTouchUpInside
{
	[self.delegate dishTileItemDidTouchUpInside:self];
}

@end
