//
//  DishTileCell.h
//  Dish by.me
//
//  Created by 전수열 on 12. 11. 16..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishTileItem.h"

@protocol DishTileCellDelegate;

@interface DishTileCell : UITableViewCell <DishTileItemDelegate>
{
	NSMutableArray *dishItems;
}

@property (nonatomic, weak) id<DishTileCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (DishTileItem *)dishItemAt:(NSInteger)index;

@end


@protocol DishTileCellDelegate

- (void)dishTileCell:(DishTileCell *)dishTileCell didSelectDishTileItem:(DishTileItem *)dishTileItem;

@end