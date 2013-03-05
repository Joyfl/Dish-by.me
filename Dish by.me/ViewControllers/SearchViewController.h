//
//  SearchViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishListCell.h"
#import "GAITrackedViewController.h"

@interface SearchViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, DishListCellDelegate>
{
	UIView *_searchBar;
	UITextField *_searchInput;
	UITableView *_tableView;
	UIView *_dimView;
	
	NSMutableArray *_dishes;
	NSInteger _count;
	NSString *_lastQuery;
	BOOL _searching;
//	NSInteger _offset;
//	BOOL _loadedLastDish;
}

@end
