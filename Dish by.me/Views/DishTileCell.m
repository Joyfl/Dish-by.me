//
//  DishTileCell.m
//  Dish by.me
//
//  Created by 전수열 on 12. 11. 16..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileCell.h"
#import "DishTileItem.h"

NSInteger DishTileGap = 8;
NSInteger DishTileLength = 96;

@implementation DishTileCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	dishItems = [[NSMutableArray alloc] initWithCapacity:3];
	
	for( NSInteger i = 0; i < 3; i++ )
	{
		DishTileItem *dishItem = [[DishTileItem alloc] initWithFrame:CGRectMake( DishTileGap * ( i + 1 ) + DishTileLength * i, 10, DishTileLength, DishTileLength )];
		dishItem.delegate = self;
		dishItem.hidden = YES;
		[self addSubview:dishItem];
		
		[dishItems addObject:dishItem];
	}
	
    return self;
}

- (DishTileItem *)dishItemAt:(NSInteger)index
{
	return [dishItems objectAtIndex:index];
}


#pragma mark -
#pragma mark DishTileItemDelegate

- (void)dishTileItemDidTouchUpInside:(DishTileItem *)dishTileItem
{
	[self.delegate dishTileCell:self didSelectDishTileItem:dishTileItem];
}

@end
