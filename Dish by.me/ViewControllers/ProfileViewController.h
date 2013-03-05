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

@class User;

@interface ProfileViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, DishListCellDelegate>
{
	User *_user;
	
	UITableView *_tableView;
	UIButton *_profileImage;
	UIImageView *_arrowView;
	
	NSMutableArray *_dishes;
	NSMutableArray *_bookmarks;
	
	NSInteger _dishOffset;
	BOOL _loadedLastDish;
	BOOL _loadingDishes;
	
	NSInteger _bookmarkOffset;
	BOOL _loadedLastBookmark;	
	BOOL _loadingBookmarks;
	
	// 0 : dishes
	// 1 : bookmarks
	NSInteger _selectedTab;
}

@property (nonatomic, assign) NSInteger userId;

@end
