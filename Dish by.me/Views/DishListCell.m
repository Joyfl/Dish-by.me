//
//  DishListCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 6..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DishListCell.h"
#import "JLHTTPLoader.h"

@implementation DishListCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	
	_photoView = [[UIImageView alloc] initWithFrame:CGRectMake( 10, 10, 300, 300 )];
#warning 임시 이미지
	_photoView.image = [UIImage imageNamed:@"dish_tile_loading.png"];
	[self.contentView addSubview:_photoView];
	
//	UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake()];
//	frameView.image = [UIImage imageNamed:@".png"];
//	[self.contentView addSubview:frameView];
	
	_commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 30, 290, 30, 15 )];
	_commentCountLabel.textColor = [UIColor whiteColor];
	[self.contentView addSubview:_commentCountLabel];
	
	_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 60, 290, 30, 15 )];
	_bookmarkCountLabel.textColor = [UIColor whiteColor];
	[self.contentView addSubview:_bookmarkCountLabel];
	
	_dishNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 10, 330, 200, 20 )];
	[self.contentView addSubview:_dishNameLabel];
	
	_userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 200, 330, 200, 20 )];
	[self.contentView addSubview:_userNameLabel];
	
	return self;
}


#pragma mark -
#pragma mark Getter/Setter

- (Dish *)dish
{
	return _dish;
}

- (void)setDish:(Dish *)dish
{
	_dish = dish;
	[self fillContents];
}


- (void)fillContents
{
	if( _dish.photo )
	{
		_photoView.image = _dish.photo;
	}
	else
	{
		[JLHTTPLoader loadAsyncFromURL:_dish.photoURL completion:^(NSData *data)
		 {
			 _photoView.image = _dish.photo = [UIImage imageWithData:data];
		 }];
	}
	
	_commentCountLabel.text = [NSString stringWithFormat:@"%d", _dish.commentCount];
	_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _dish.bookmarkCount];
	_dishNameLabel.text = _dish.dishName;
	_userNameLabel.text = [NSString stringWithFormat:@"by %@", _dish.userName];
}

//- (void)layoutContentView
//{
//	
//}

@end
