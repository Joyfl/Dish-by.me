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
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_photoView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 12, 292, 292 )];
	_photoView.image = [UIImage imageNamed:@"placeholder.png"];
	[self.contentView addSubview:_photoView];
	
	UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, 350 )];
	frameView.image = [UIImage imageNamed:@"dish_border_big.png"];
	[self.contentView addSubview:frameView];
	
	_commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 30, 290, 30, 15 )];
	_commentCountLabel.textColor = [UIColor whiteColor];
	_commentCountLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:_commentCountLabel];
	
	_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 60, 290, 30, 15 )];
	_bookmarkCountLabel.textColor = [UIColor whiteColor];
	_bookmarkCountLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:_bookmarkCountLabel];
	
	_dishNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 10, 310, 200, 20 )];
	[self.contentView addSubview:_dishNameLabel];
	
	_userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 200, 310, 200, 20 )];
	[self.contentView addSubview:_userNameLabel];
	
	return self;
}


#pragma mark -
#pragma mark Getter/Setter

- (Dish *)dish
{
	return _dish;
}

- (void)setDish:(Dish *)dish atIndexPath:(NSIndexPath *)indexPath
{
	_dish = [dish retain];
	_indexPath = [indexPath retain];
	[self fillContents];
}


- (void)fillContents
{
	_photoView.image = [UIImage imageNamed:@"placeholder.png"];
	if( _dish.photo )
	{
		_photoView.image = _dish.photo;
	}
	else
	{
		[JLHTTPLoader loadAsyncFromURL:_dish.photoURL withObject:_indexPath completion:^(id indexPath, NSData *data)
		{
			_dish.photo = [UIImage imageWithData:data];
			
			if( [_indexPath isEqual:indexPath] )
				_photoView.image = _dish.photo;
		}];
	}
	
	_commentCountLabel.text = [NSString stringWithFormat:@"%d", _dish.commentCount];
	_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _dish.bookmarkCount];
	_dishNameLabel.text = _dish.dishName;
	_userNameLabel.text = [NSString stringWithFormat:@"by %@", _dish.userName];
}

@end
