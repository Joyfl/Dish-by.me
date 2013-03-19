//
//  MeViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "DishTileCell.h"
#import "EGORefreshTableHeaderView.h"

@class User;

@interface ProfileViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, DishTileCellDelegate>
{
	User *_user;
	
	UITableView *_tableView;
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	UIButton *_userPhotoButton;
	
	UILabel *_nameLabel;
	UILabel *_bioLabel;
	
	UILabel *_dishCountLabel;
	UILabel *_bookmarkCountLabel;
	UILabel *_followingCountLabel;
	UILabel *_followersCountLabel;
	
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

- (void)loadUserId:(NSInteger)userId;

@end
