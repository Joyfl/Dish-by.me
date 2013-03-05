//
//  MeViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "DishListCell.h"
#import "EGORefreshTableHeaderView.h"

@class User;

@interface ProfileViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, DishListCellDelegate>
{
	User *_user;
	
	UITableView *_tableView;
	EGORefreshTableHeaderView *_refreshHeaderView;
	UIButton *_profileImage;
	UILabel *_bioLabel;
	UILabel *_dishCountLabel;
	UILabel *_dishLabel;
	UILabel *_bookmarkCountLabel;
	UILabel *_bookmarkLabel;
	UIImageView *_arrowView;
	
	BOOL _updating;
	
	NSMutableArray *_dishes;
	BOOL _loadingDishes;
	
	NSMutableArray *_bookmarks;
	BOOL _loadingBookmarks;
	
	// 0 : dishes
	// 1 : bookmarks
	NSInteger _selectedTab;
}

@property (nonatomic, assign) NSInteger userId;

@end
