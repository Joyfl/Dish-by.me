//
//  DishTileCell.m
//  Dish by.me
//
//  Created by 전수열 on 12. 11. 16..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishTileCell.h"
#import "DishTileItem.h"

@implementation DishTileCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier target:(id)target action:(SEL)action
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	dishItems = [[NSMutableArray alloc] initWithCapacity:3];
	
	for( NSInteger i = 0; i < 3; i++ )
	{
		DishTileItem *dishItem = [[DishTileItem alloc] init];
		dishItem.frame = CGRectMake( DISH_TILE_GAP * ( i + 1 ) + DISH_TILE_LEN * i, DISH_TILE_GAP, DISH_TILE_LEN, DISH_TILE_LEN );
		dishItem.hidden = YES;
		[dishItem addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dishItem];
		
		[dishItems addObject:dishItem];
	}
	
    return self;
}

- (DishTileItem *)dishItemAt:(NSInteger)index
{
	return [dishItems objectAtIndex:index];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
