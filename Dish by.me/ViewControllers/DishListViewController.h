//
//  DishViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "DishListCell.h"
#import "GAITrackedViewController.h"
#import "WritingViewController.h"

@interface DishListViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, DishListCellDelegate>
{
	UITableView *_tableView;
//	NSMutableArray *_dishes;
	NSInteger _offset;
	BOOL _loadedLastDish;
	
	BOOL _loading;
	BOOL _updating;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	NSTimer *_scrollTimer; // 스크롤 후 일정시간이 지나면 DishListCell에서 프로필을 fade out시킨다.
}

@property (nonatomic, strong) NSMutableArray *dishes;

- (void)updateDishes;

@end
