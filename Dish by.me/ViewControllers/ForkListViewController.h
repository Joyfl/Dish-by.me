//
//  ForkListViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 13..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "DishTileCell.h"
#import "Dish.h"

@interface ForkListViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, DishTileCellDelegate>
{
	UITableView *_tableView;
	
	Dish *_dish;
	NSMutableArray *_dishes;
	BOOL _loading;
}

- (id)initWithDish:(Dish *)dish;

@end
