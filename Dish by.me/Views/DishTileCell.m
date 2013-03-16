//
//  DishTileCell.m
//  Dish by.me
//
//  Created by 전수열 on 12. 11. 16..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileCell.h"
#import "DishTileItem.h"

NSInteger DishTileGap = 14;
NSInteger DishTileLength = 88;

@implementation DishTileCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	dishItems = [[NSMutableArray alloc] initWithCapacity:3];
	
	for( NSInteger i = 0; i < 3; i++ )
	{
		DishTileItem *dishItem = [[DishTileItem alloc] init];
		dishItem.frame = CGRectMake( DishTileGap * ( i + 1 ) + DishTileLength * i, 10, DishTileLength, DishTileLength );
		dishItem.adjustsImageWhenHighlighted = NO;
		dishItem.hidden = YES;
		[dishItem addTarget:self action:@selector(dishItemDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dishItem];
		
		[dishItems addObject:dishItem];
	}
	
    return self;
}

- (DishTileItem *)dishItemAt:(NSInteger)index
{
	return [dishItems objectAtIndex:index];
}

- (void)dishItemDidTouchUpInside:(DishTileItem *)dishTileItem
{
	[self.delegate dishTileCell:self didSelectDishTileItem:dishTileItem];
}

@end
