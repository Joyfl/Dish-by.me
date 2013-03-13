//
//  DishTileCell.h
//  Dish by.me
//
//  Created by 전수열 on 12. 11. 16..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

NSInteger DishTileGap = 14;
NSInteger DishTileLength = 88;

@class DishTileItem;

@interface DishTileCell : UITableViewCell
{
	NSMutableArray *dishItems;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier target:(id)target action:(SEL)action;
- (DishTileItem *)dishItemAt:(NSInteger)index;

@end
