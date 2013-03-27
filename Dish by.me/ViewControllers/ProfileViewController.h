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
#import "UserListCell.h"
#import "EGORefreshTableHeaderView.h"
#import "DMBarButtonItem.h"
#import "User.h"

@interface ProfileViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, DishTileCellDelegate, UserListCellDelegate>
{
	User *_user;
	
	DMBarButtonItem *_followButton;
	DMBarButtonItem *_followingButton;
	
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
	
	UILabel *_messageLabel;
	
	BOOL _updating;
	
	NSMutableArray *_dishes;
	BOOL _loadingDishes;
	
	NSMutableArray *_bookmarks;
	BOOL _loadingBookmarks;
	
	NSMutableArray *_following;
	BOOL _loadingFollowing;
	
	NSMutableArray *_followers;
	BOOL _loadingFollowers;
	
	
	// 0 : dishes
	// 1 : bookmarks
	// 2 : following
	// 3 : followers
	NSInteger _selectedTab;
}

- (void)loadUserId:(NSInteger)userId;

@end
