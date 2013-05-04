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

@interface SearchViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, DishListCellDelegate, UISearchBarDelegate>
{
	UISearchBar *_searchBar;
	UIButton *_searchButton;
	UITableView *_tableView;
	UILabel *_messageLabel;
	UIView *_dimView;
	
	NSMutableArray *_dishes;
	NSInteger _count;
	NSString *_lastQuery;
	BOOL _searching;
//	NSInteger _offset;
//	BOOL _loadedLastDish;
	
	NSTimer *_scrollTimer; // 스크롤 후 일정시간이 지나면 DishListCell에서 프로필을 fade out시킨다.
}

@end
