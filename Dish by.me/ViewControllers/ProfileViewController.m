//
//  MeViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "ProfileViewController.h"
#import "Utils.h"
#import "Dish.h"
#import "DishDetailViewController.h"
#import "CurrentUser.h"
#import "DMAPILoader.h"
#import "DMBarButtonItem.h"
#import "AppDelegate.h"
#import "DMTextFieldViewController.h"
#import "HTBlock.h"
#import "UIButton+ActivityIndicatorView.h"
#import "NotificationListViewController.h"
#import "DMPhotoViewerViewController.h"

#define isLastDishLoaded ( _dishes.count == _user.dishCount )
#define isLastBookmarkLoaded ( _bookmarks.count == _user.bookmarkCount )
#define isLastFollowingLoaded ( _following.count == _user.followingCount )
#define isLastFollowerLoaded ( _followers.count == _user.followersCount )

#define selectedDishArray ( _selectedTab == 0 ? _dishes : _bookmarks )
#define selectedUserArray ( _selectedTab == 2 ? _following : _followers )

#define userNameWithPlaceholder ( _user.name.length > 0 ? _user.name : NSLocalizedString( @"NO_NAME", nil ) )
#define userBioWithPlaceholder ( _user.bio.length > 0 ? _user.bio : NSLocalizedString( @"NO_BIO", nil ) )


const NSInteger arrowXPositions[] = {36, 110, 185, 260};

@implementation ProfileViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	
	_followButton = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"FOLLOW", nil ) target:self action:@selector(followButtonHandler)];
	_followingButton = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"FOLLOWING", nil ) target:self action:@selector(followingButtonHandler)];
	_followingButton.button.imageEdgeInsets = UIEdgeInsetsMake( 0, 0, 0, 8 );
	[_followingButton.button setImage:[UIImage imageNamed:@"icon_checkmark.png"] forState:UIControlStateNormal];
	[_followingButton updateFrame];
	
	_notificationsButton = [DMBarButtonItem barButtonItemWithTitle:@"0" target:self action:@selector(notificationsButtonHandler)];
	_notificationsButton.button.imageEdgeInsets = UIEdgeInsetsMake( 0, 0, 0, 12 );
	[_notificationsButton.button setImage:[UIImage imageNamed:@"icon_notification.png"] forState:UIControlStateNormal];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:_tableView];
	
	_userPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake( 12, 13, 85, 85 )];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake( 0, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height )];
	_refreshHeaderView.delegate = self;
	_refreshHeaderView.backgroundColor = self.view.backgroundColor;
	[_tableView addSubview:_refreshHeaderView];
	
	_messageLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 236, UIScreenWidth, 0 )];
	_messageLabel.font = [UIFont boldSystemFontOfSize:15];
	_messageLabel.numberOfLines = 0;
	_messageLabel.textAlignment = NSTextAlignmentCenter;
	_messageLabel.backgroundColor = [UIColor clearColor];
	_messageLabel.textColor = [UIColor colorWithHex:0x717374 alpha:1];
	_messageLabel.shadowColor = [UIColor whiteColor];
	_messageLabel.shadowOffset = CGSizeMake( 0, 1 );
	_messageLabel.hidden = YES;
	[_tableView addSubview:_messageLabel];
	
	_dishes = [NSMutableArray array];
	_bookmarks = [NSMutableArray array];
	_following = [NSMutableArray array];
	_followers = [NSMutableArray array];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	// 프로필 탭
	if( self == [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController] )
	{
		self.navigationItem.leftBarButtonItem = nil;
		self.trackedViewName = @"ProfileViewController (Tab)";
	}
	else
	{
		[DMBarButtonItem setBackButtonToViewController:self];
		self.trackedViewName = [[self class] description];
	}
}

- (void)updateFollowFollowingButton
{
	if( _user.userId != [CurrentUser user].userId )
	{
		if( !_user.following )
			self.navigationItem.rightBarButtonItem = _followButton;
		else
			self.navigationItem.rightBarButtonItem = _followingButton;
	}
	else
	{
		self.navigationItem.rightBarButtonItem = _notificationsButton;
	}
}

- (void)setNotificationsCount:(NSInteger)notificationsCount
{
	NSString *badge = [NSString stringWithFormat:@"%d", notificationsCount];
	JLLog( @"badge : %@", badge );
	_notificationsButton.title = badge;
	self.tabBarItem.badgeValue = notificationsCount > 0 ? badge : nil;
	[UIApplication sharedApplication].applicationIconBadgeNumber = notificationsCount;
}

- (void)notificationsButtonHandler
{
	NotificationListViewController *notificationListViewController = [[NotificationListViewController alloc] init];
	[notificationListViewController updateNotifications];
	[self.navigationController pushViewController:notificationListViewController animated:YES];
}

- (void)followButtonHandler
{
	_followButton.button.showsActivityIndicatorView = YES;
	[self followUser:_user success:^{
		
		_user.following = YES;
		_user.followersCount ++;
		[_followers addObject:[CurrentUser user]];
		
		_followButton.button.showsActivityIndicatorView = NO;
		
		[self updateFollowFollowingButton];
		[_tableView reloadData];
		
	} failure:^(NSInteger errorCode) {
		
	}];
}

- (void)followingButtonHandler
{
	_followingButton.button.showsActivityIndicatorView = YES;
	[self unfollowUser:_user success:^{
		
		_user.following = NO;
		_user.followersCount --;
		for( User *follower in _followers )
		{
			if( follower.userId == [CurrentUser user].userId )
			{
				[_followers removeObject:follower];
				break;
			}
		}
		
		_followingButton.button.showsActivityIndicatorView = NO;
		
		[self updateFollowFollowingButton];
		[_tableView reloadData];
		
	} failure:nil];
}


#pragma mark -
#pragma mark Loading

- (void)loadUserId:(NSInteger)userId
{
	[_dishes removeAllObjects];
	[_bookmarks removeAllObjects];
	[_following removeAllObjects];
	[_followers removeAllObjects];
	[_tableView reloadData];
	
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", userId] method:@"GET" parameters:nil success:^(id response) {
		_user = [User userFromDictionary:response];
		[self updateUserPhoto];
		
		self.navigationItem.title = userNameWithPlaceholder;
		[self updateFollowFollowingButton];
		
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)loadMoreDishes
{
	JLLog( @"loadMoreDishes" );
	_loadingDishes = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _dishes.count], @"limit": @"30" };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/dishes", _user.userId] method:@"GET" parameters:params success:^(id response) {
		JLLog( @"loadMoreDishes success" );
		
		_loadingDishes = NO;
		
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		if( _selectedTab == 0 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		_loadingDishes = NO;
	}];
}

- (void)loadMoreBookmarks
{
	JLLog( @"loadMoreBookmarks" );
	_loadingBookmarks = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _bookmarks.count], @"limit": @"30" };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/bookmarks", _user.userId] method:@"GET" parameters:params success:^(id response) {
		JLLog( @"loadMoreBookmarks success" );
		
		_loadingBookmarks = NO;
		
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_bookmarks addObject:dish];
		}
		
		if( _selectedTab == 1 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		_loadingBookmarks = NO;
	}];
}

- (void)loadMoreFollowing
{
	JLLog( @"loadMoreFollowing" );
	
	_loadingFollowing = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _following.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/following", _user.userId] method:@"GET" parameters:params success:^(id response) {
		JLLog( @"loadMoreFollowing success" );
		
		_loadingFollowing = NO;
		
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			User *dish = [User userFromDictionary:d];
			[_following addObject:dish];
		}
		
		if( _selectedTab == 2 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		_loadingFollowing = NO;
	}];
}

- (void)loadMoreFollowers
{
	_loadingFollowers = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _followers.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/followers", _user.userId] method:@"GET" parameters:params success:^(id response) {
		JLLog( @"loadMoreFollowers success" );
		
		_loadingFollowers = NO;
		NSLog( @"%@", response );
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			User *dish = [User userFromDictionary:d];
			[_followers addObject:dish];
		}
		
		if( _selectedTab == 3 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		_loadingFollowers = NO;
	}];
}

- (void)updateUser
{	
	_updating = YES;
	
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", _user.userId] method:@"GET" parameters:nil success:^(id response) {
		_user.userId = [[response objectForKeyNotNull:@"id"] integerValue];
		_user.name = [response objectForKeyNotNull:@"name"];
		_user.photoURL = [response objectForKeyNotNull:@"photo_url"];
		_user.thumbnailURL = [response objectForKeyNotNull:@"thumbnail_url"];
		_user.bio = [response objectForKeyNotNull:@"bio"];
		_user.dishCount = [[response objectForKeyNotNull:@"dish_count"] integerValue];
		_user.bookmarkCount = [[response objectForKeyNotNull:@"bookmark_count"] integerValue];
		_user.followingCount = [[response objectForKeyNotNull:@"following_count"] integerValue];
		_user.followersCount = [[response objectForKeyNotNull:@"followers_count"] integerValue];
		_user.following = [[response objectForKeyNotNull:@"following"] boolValue];
		
		self.navigationItem.title = userNameWithPlaceholder;
		
		[self updateDishes];
		[self updateBookmarks];
		[self updateFollowing];
		[self updateFollowers];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)updateDishes
{
	_updating = YES;
	
	NSDictionary *params = @{ @"limit": @"30" };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/dishes", _user.userId] method:@"GET" parameters:params success:^(id response) {
		[_dishes removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		if( _selectedTab == 0 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)updateBookmarks
{
	_updating = YES;
	
	NSDictionary *params = @{ @"limit": @"30" };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/bookmarks", _user.userId] method:@"GET" parameters:params success:^(id response) {
		[_bookmarks removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_bookmarks addObject:dish];
		}
		
		if( _selectedTab == 1 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)updateFollowing
{
	JLLog( @"updateFollowing" );
	
	_updating = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _following.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/following", _user.userId] method:@"GET" parameters:params success:^(id response) {
		JLLog( @"updateFollowing success" );
		
		[_following removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			User *dish = [User userFromDictionary:d];
			[_following addObject:dish];
		}
		
		if( _selectedTab == 2 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)updateFollowers
{
	JLLog( @"updateFollowers" );
	
	_updating = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _followers.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/followers", _user.userId] method:@"GET" parameters:params success:^(id response) {
		JLLog( @"updateFollowers success" );
		
		[_followers removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			User *dish = [User userFromDictionary:d];
			[_followers addObject:dish];
		}
		
		if( _selectedTab == 3 )
			[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		_loadingFollowers = NO;
	}];
}

- (void)bookmarkDish:(Dish *)dish
{
	JLLog( @"bookmarkDish" );
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)unbookmarkDish:(Dish *)dish
{
	JLLog( @"unbookmarkDish" );
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)followUser:(User *)user success:(void (^)(void))success failure:(void (^)(NSInteger errorCode))failure
{
	JLLog( @"Follow" );
	
	NSString *api = [NSString stringWithFormat:@"/user/%d/follow", user.userId];
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
		JLLog( @"Follow Succeed" );
		
		if( success )
			success();
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		if( failure )
			failure( errorCode );
	}];
}

- (void)unfollowUser:(User *)user success:(void (^)(void))success failure:(void (^)(NSInteger errorCode))failure
{
	JLLog( @"Follow" );
	
	NSString *api = [NSString stringWithFormat:@"/user/%d/follow", user.userId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Unfollow Succeed" );
		
		if( success )
			success();
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		if( failure )
			failure( errorCode );
	}];
}

- (void)editUserInfo:(NSDictionary *)userInfo
{
	[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" parameters:userInfo success:^(id response) {
		JLLog( @"Succeed" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)uploadUserPhoto:(UIImage *)photo
{
	[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" image:photo forName:@"photo" fileName:@"photo" parameters:nil success:^(id response) {
		JLLog( @"Succeed" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)updateUserPhoto
{
	[_userPhotoButton setBackgroundImageWithURL:[NSURL URLWithString:_user.thumbnailURL] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"] forState:UIControlStateNormal];
	[_userPhotoButton setBackgroundImageWithURL:[NSURL URLWithString:_user.photoURL] placeholderImage:[_userPhotoButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)refreshHeaerView
{
	[self updateUser];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)refreshHeaerView
{
	return _updating;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)refreshHeaerView
{
	return [NSDate date];
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2 + ( _selectedTab == 0 ? !isLastDishLoaded :
				_selectedTab == 1 ? !isLastBookmarkLoaded :
				_selectedTab == 2 ? !isLastFollowingLoaded : !isLastFollowerLoaded );
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 ) return 1;
	else if( section == 2 ) return 1;
	
	[self updateMessageLabelText];
	
	if( _selectedTab < 2 )
		return ceil( selectedDishArray.count / 3.0 );
	return selectedUserArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 ) return 155;
	else if( indexPath.section == 2 ) return 45;
	
	if( _selectedTab < 2 )
	{
		if( indexPath.row == ceil( selectedDishArray.count / 3.0 ) - 1 )
			return 116;
		return 102;
	}
	
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *profileCellId = @"profileCell";
	static NSString *dishCellId = @"dishCell";
	static NSString *userCellId = @"userCell";
	
	//
	// Profile
	//
	if( indexPath.section == 0 )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileCellId];
		if( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			//
			// Photo
			//
			[_userPhotoButton addTarget:self action:@selector(userPhotoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:_userPhotoButton];
			
			UIImageView *profileBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_border.png"]];
			profileBorder.frame = CGRectMake( 8, 8, 93, 93 );
			[cell.contentView addSubview:profileBorder];
			
			
			//
			// Name
			//
			UIButton *nameButton = [[UIButton alloc] initWithFrame:CGRectMake( 101, 8, 211, 48 )];
			nameButton.titleLabel.font = [UIFont systemFontOfSize:13];
			nameButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			nameButton.adjustsImageWhenHighlighted = NO;
			[nameButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top.png"] forState:UIControlStateNormal];
			[nameButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top_selected.png"] forState:UIControlStateHighlighted];
			[nameButton addTarget:self action:@selector(nameButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:nameButton];
			
			_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 8, 10, 165, 30 )];
			_nameLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			_nameLabel.font = [UIFont systemFontOfSize:13];
			_nameLabel.backgroundColor = [UIColor clearColor];
			[nameButton addSubview:_nameLabel];
			
			
			//
			// Bio
			//
			UIButton *bioButton = [[UIButton alloc] initWithFrame:CGRectMake( 101, 56, 211, 45 )];
			bioButton.titleLabel.font = [UIFont systemFontOfSize:13];
			bioButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			bioButton.adjustsImageWhenHighlighted = NO;
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_mid.png"] forState:UIControlStateNormal];
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_mid_selected.png"] forState:UIControlStateHighlighted];
			[bioButton addTarget:self action:@selector(bioButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:bioButton];
			
			_bioLabel = [[UILabel alloc] initWithFrame:CGRectMake( 8, 8, 165, 30 )];
			_bioLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			_bioLabel.font = [UIFont systemFontOfSize:13];
			_bioLabel.backgroundColor = [UIColor clearColor];
			_bioLabel.numberOfLines = 2;
			[bioButton addSubview:_bioLabel];
			
			// My profile
			if( _user.userId == [[CurrentUser user] userId] )
			{
				nameButton.imageEdgeInsets = UIEdgeInsetsMake( 4, 170, 0, 0 );
				[nameButton setImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
				nameButton.userInteractionEnabled = YES;
				
				bioButton.imageEdgeInsets = UIEdgeInsetsMake( 4, 170, 0, 0 );
				[bioButton setImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
				bioButton.userInteractionEnabled = YES;
			}
			else
			{
				nameButton.userInteractionEnabled = NO;
				bioButton.userInteractionEnabled = NO;
			}
			
			
			//
			// Dishes
			//
			UIButton *dishButton = [[UIButton alloc] initWithFrame:CGRectMake( 8, 101, 77, 47 )];
			dishButton.tag = 0;
			[dishButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_1.png"] forState:UIControlStateNormal];
			[dishButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_1_selected.png"] forState:UIControlStateHighlighted];
			[dishButton addTarget:self action:@selector(tabDidTouchDown:) forControlEvents:UIControlEventTouchDown];
			[dishButton addTarget:self action:@selector(tabDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
			[dishButton addTarget:self action:@selector(tabDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			dishButton.adjustsImageWhenHighlighted = NO;
			[cell.contentView addSubview:dishButton];
			
			_dishCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 3, 5, 74, 20 )];
			_dishCountLabel.userInteractionEnabled = NO;
			_dishCountLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			_dishCountLabel.textAlignment = NSTextAlignmentCenter;
			_dishCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_dishCountLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:_dishCountLabel];
			
			UILabel *dishLabel = [[UILabel alloc] initWithFrame:CGRectMake( 3, 21, 74, 20 )];
			dishLabel.text = NSLocalizedString( @"DISHES", @"" );
			dishLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			dishLabel.textAlignment = NSTextAlignmentCenter;
			dishLabel.font = [UIFont systemFontOfSize:13];
			dishLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:dishLabel];
			
			
			//
			// Bookmarks
			//
			UIButton *bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake( dishButton.frame.origin.x + dishButton.frame.size.width, dishButton.frame.origin.y, 75, 47 )];
			bookmarkButton.tag = 1;
			[bookmarkButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_2.png"] forState:UIControlStateNormal];
			[bookmarkButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_2_selected.png"] forState:UIControlStateHighlighted];
			[bookmarkButton addTarget:self action:@selector(tabDidTouchDown:) forControlEvents:UIControlEventTouchDown];
			[bookmarkButton addTarget:self action:@selector(tabDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
			[bookmarkButton addTarget:self action:@selector(tabDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			bookmarkButton.adjustsImageWhenHighlighted = NO;
			[cell.contentView addSubview:bookmarkButton];
			
			_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 5, 75, 20 )];
			_bookmarkCountLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			_bookmarkCountLabel.textAlignment = NSTextAlignmentCenter;
			_bookmarkCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_bookmarkCountLabel.backgroundColor = [UIColor clearColor];
			[bookmarkButton addSubview:_bookmarkCountLabel];
			
			UILabel *bookmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 21, 75, 20 )];
			bookmarkLabel.text = NSLocalizedString( @"BOOKMARKS", @"" );
			bookmarkLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			bookmarkLabel.textAlignment = NSTextAlignmentCenter;
			bookmarkLabel.font = [UIFont systemFontOfSize:13];
			bookmarkLabel.backgroundColor = [UIColor clearColor];
			[bookmarkButton addSubview:bookmarkLabel];
			
			
			//
			// Following
			//
			UIButton *followingButton = [[UIButton alloc] initWithFrame:CGRectOffset( bookmarkButton.frame, bookmarkButton.frame.size.width, 0 )];
			followingButton.tag = 2;
			[followingButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_2.png"] forState:UIControlStateNormal];
			[followingButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_2_selected.png"] forState:UIControlStateHighlighted];
			[followingButton addTarget:self action:@selector(tabDidTouchDown:) forControlEvents:UIControlEventTouchDown];
			[followingButton addTarget:self action:@selector(tabDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
			[followingButton addTarget:self action:@selector(tabDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			followingButton.adjustsImageWhenHighlighted = NO;
			[cell.contentView addSubview:followingButton];
			
			_followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 5, 75, 20 )];
			_followingCountLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			_followingCountLabel.textAlignment = NSTextAlignmentCenter;
			_followingCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_followingCountLabel.backgroundColor = [UIColor clearColor];
			[followingButton addSubview:_followingCountLabel];
			
			UILabel *followingLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 21, 75, 20 )];
			followingLabel.text = NSLocalizedString( @"FOLLOWING", @"" );
			followingLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			followingLabel.textAlignment = NSTextAlignmentCenter;
			followingLabel.font = [UIFont systemFontOfSize:13];
			followingLabel.backgroundColor = [UIColor clearColor];
			[followingButton addSubview:followingLabel];
			
			
			//
			// Followers
			//
			UIButton *followersButton = [[UIButton alloc] initWithFrame:CGRectMake( followingButton.frame.origin.x + followingButton.frame.size.width, dishButton.frame.origin.y, 77, 47 )];
			followersButton.tag = 3;
			[followersButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_3.png"] forState:UIControlStateNormal];
			[followersButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bot_3_selected.png"] forState:UIControlStateHighlighted];
			[followersButton addTarget:self action:@selector(tabDidTouchDown:) forControlEvents:UIControlEventTouchDown];
			[followersButton addTarget:self action:@selector(tabDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
			[followersButton addTarget:self action:@selector(tabDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			followersButton.adjustsImageWhenHighlighted = NO;
			[cell.contentView addSubview:followersButton];
			
			_followersCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 5, 74, 20 )];
			_followersCountLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			_followersCountLabel.textAlignment = NSTextAlignmentCenter;
			_followersCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_followersCountLabel.backgroundColor = [UIColor clearColor];
			[followersButton addSubview:_followersCountLabel];
			
			UILabel *followersLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 21, 74, 20 )];
			followersLabel.text = NSLocalizedString( @"FOLLOWERS", @"" );
			followersLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			followersLabel.textAlignment = NSTextAlignmentCenter;
			followersLabel.font = [UIFont systemFontOfSize:13];
			followersLabel.backgroundColor = [UIColor clearColor];
			[followersButton addSubview:followersLabel];
			
			
			//
			// Arrow
			//
			_arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_arrow.png"]];
			[cell.contentView addSubview:_arrowView];
		}
		
		[self updateUserPhoto];
		
		_nameLabel.text = userNameWithPlaceholder;
		_bioLabel.text = userBioWithPlaceholder;
		_dishCountLabel.text = [NSString stringWithFormat:@"%d", _user.dishCount];
		_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _user.bookmarkCount];
		_followingCountLabel.text = [NSString stringWithFormat:@"%d", _user.followingCount];
		_followersCountLabel.text = [NSString stringWithFormat:@"%d", _user.followersCount];
		_arrowView.frame = CGRectMake( arrowXPositions[_selectedTab], 145, 25, 11 );
		
		return cell;
	}
	
	else if( indexPath.section == 1 )
	{
		if( _selectedTab < 2 )
		{
			DishTileCell *cell = [_tableView dequeueReusableCellWithIdentifier:dishCellId];
			
			if( !cell )
			{
				cell = [[DishTileCell alloc] initWithReuseIdentifier:dishCellId];
				cell.delegate = self;
			}
			
			for( NSInteger i = 0; i < 3; i++ )
			{
				DishTileItem *dishItem = [cell dishItemAt:i];
				if( selectedDishArray.count > indexPath.row * 3 + i )
				{
					dishItem.hidden = NO;
					
					Dish *dish = [selectedDishArray objectAtIndex:indexPath.row * 3 + i];
					dishItem.dish = dish;
				}
				else
				{
					dishItem.hidden = YES;
				}
			}
			
			return cell;
		}
		else
		{
			UserListCell *cell = [_tableView dequeueReusableCellWithIdentifier:userCellId];
			
			if( !cell )
			{
				cell = [[UserListCell alloc] initWithReuseIdentifier:userCellId];
				cell.delegate = self;
			}
			
			[cell setUser:[selectedUserArray objectAtIndex:indexPath.row] atIndexPath:indexPath];
			
			return cell;
		}
	}
	
	else
	{
		static NSString *activityIndicatorCellId = @"activityIndicatorCellId";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:activityIndicatorCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:activityIndicatorCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicator.frame = CGRectMake( 141, 0, 37, 37 );
		[indicator startAnimating];
		[cell.contentView addSubview:indicator];
		
		if( !_loadingDishes && _selectedTab == 0 )
			[self loadMoreDishes];
		
		else if( !_loadingBookmarks && _selectedTab == 1 )
			[self loadMoreBookmarks];
		
		else if( !_loadingFollowing && _selectedTab == 2 )
			[self loadMoreFollowing];
		
		else if( !_loadingFollowers && _selectedTab == 3 )
			[self loadMoreFollowers];
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 1 )
	{
		User *user = [selectedUserArray objectAtIndex:indexPath.row];
		ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
		[profileViewController loadUserId:user.userId];
		[self.navigationController pushViewController:profileViewController animated:YES];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark Selectors

- (void)userPhotoButtonDidTouchUpInside
{
	// 내 프로필
	if( _user.userId == [CurrentUser user].userId )
	{
		[[[UIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString( @"TAKE_A_PHOTO", nil ), NSLocalizedString( @"FROM_LIBRARY", nil )] dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
			
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			
			if( buttonIndex == 0 ) // Camera
			{
				@try
				{
					picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				}
				@catch( NSException *exception )
				{
					[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"MESSAGE_NO_SUPPORT_CAMERA", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] show];
					return;
				}
				
				picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
			}
			else if( buttonIndex == 1 ) // Album
			{
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			}
			else
			{
				return;
			}
			
			picker.allowsEditing = YES;
			[self presentViewController:picker animated:YES completion:nil];
			
			[picker setFinishBlock:^(UIImagePickerController *picker, NSDictionary *info) {
				[picker dismissViewControllerAnimated:YES completion:nil];
				
				UIImage *image = [Utils scaleAndRotateImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
				
				// 카메라로 찍은 경우 앨범에 저장
				if( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
					UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
				
				[_userPhotoButton setBackgroundImage:image forState:UIControlStateNormal];
				[self uploadUserPhoto:image];
			}];
			
			[picker setCancelBlock:^(UIImagePickerController *picker) {
				[picker dismissViewControllerAnimated:YES completion:nil];
			}];
			
		}] showInView:[[UIApplication sharedApplication] keyWindow]];
	}
	
	// 다른 사람의 프로필
	else
	{
		DMPhotoViewerViewController *photoViewer = [[DMPhotoViewerViewController alloc] initWithPhotoURL:[NSURL URLWithString:_user.photoURL] thumbnailImage:[_userPhotoButton backgroundImageForState:UIControlStateNormal]];
		photoViewer.originRect = [photoViewer.view convertRect:_userPhotoButton.frame fromView:_tableView];
		self.tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self presentViewController:photoViewer animated:NO completion:nil];
	}
}

- (void)nameButtonDidTouchUpInside
{
	DMTextFieldViewController *textFieldViewController = [[DMTextFieldViewController alloc] initWithTitle:NSLocalizedString( @"NAME", nil ) shouldComplete:^BOOL(DMTextFieldViewController *textFieldViewController, NSString *text) {
		_user.name = text;
		[self editUserInfo:@{ @"name": text }];
		self.navigationItem.title = userNameWithPlaceholder;
		return YES;
	}];
	textFieldViewController.trackedViewName = @"DMTextFieldViewController (Name)";
	textFieldViewController.textField.text = _user.name;
	textFieldViewController.textField.placeholder = userNameWithPlaceholder;
	[self.navigationController pushViewController:textFieldViewController animated:YES];
}

- (void)bioButtonDidTouchUpInside
{
	DMTextFieldViewController *textFieldViewController = [[DMTextFieldViewController alloc] initWithTitle:NSLocalizedString( @"BIO", nil ) shouldComplete:^BOOL(DMTextFieldViewController *textFieldViewController, NSString *text) {
		_user.bio = text;
		[self editUserInfo:@{ @"bio": text }];
		[_tableView reloadData];
		return YES;
	}];
	textFieldViewController.trackedViewName = @"DMTextFieldViewController (Bio)";
	textFieldViewController.textField.text = _user.bio;
	textFieldViewController.textField.placeholder = userBioWithPlaceholder;
	[self.navigationController pushViewController:textFieldViewController animated:YES];
}

- (void)tabDidTouchDown:(UIButton *)button
{
	if( _selectedTab == button.tag )
		_arrowView.image = [UIImage imageNamed:@"profile_arrow_selected.png"];
}

- (void)tabDidTouchUp:(UIButton *)button
{
	_arrowView.image = [UIImage imageNamed:@"profile_arrow.png"];
}

- (void)tabDidTouchUpInside:(UIButton *)button
{
	_selectedTab = button.tag;
	[_tableView reloadData];
}

- (void)updateMessageLabelText
{
	if( !_user.name ) return;
	
	if( _selectedTab == 0 && _dishes.count == 0 && isLastDishLoaded && !_loadingDishes )
	{
		_messageLabel.text = [NSString stringWithFormat:NSLocalizedString( @"NO_DISHES", nil ), _user.name];
	}
	else if( _selectedTab == 1 && _bookmarks.count == 0 && isLastBookmarkLoaded && !_loadingBookmarks )
	{
		_messageLabel.text = [NSString stringWithFormat:NSLocalizedString( @"NO_BOOKMARKS", nil ), _user.name];
	}
	else if( _selectedTab == 2 && _following.count == 0 && isLastFollowingLoaded && !_loadingFollowing )
	{
		_messageLabel.text = [NSString stringWithFormat:NSLocalizedString( @"NO_FOLLOWING", nil ), _user.name];
	}
	else if( _selectedTab == 3 && _followers.count == 0 && isLastFollowerLoaded && !_loadingFollowers )
	{
		_messageLabel.text = [NSString stringWithFormat:NSLocalizedString( @"NO_FOLLOWERS", nil ), _user.name];
	}
	else
	{
		_messageLabel.hidden = YES;
		return;
	}
	
	_messageLabel.hidden = NO;
	[_messageLabel sizeToFit];
	_messageLabel.frame = CGRectMake( 0, 236, 320, _messageLabel.frame.size.height );
}


#pragma mark -
#pragma mark DishTileCellDelegate

- (void)dishTileCell:(DishTileCell *)dishTileCell didSelectDishTileItem:(DishTileItem *)dishTileItem
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}


#pragma mark -
#pragma mark UserListCellDelegate

- (void)userListCell:(UserListCell *)userListCell didTouchFollowButtonAtIndexPath:(NSIndexPath *)indexPath
{
	User *user = [selectedUserArray objectAtIndex:indexPath.row];
	[self followUser:user success:^{
		
		user.following = YES;
		
		userListCell.followButton.showsActivityIndicatorView = NO;
		[userListCell setUser:user atIndexPath:indexPath];
		
		// 내 프로필을 보고 있을 경우에만
		if( _user.userId == [CurrentUser user].userId )
		{
			_user.followingCount ++;
			[_following addObject:user];
			[_tableView reloadData];
		}
		
	} failure:^(NSInteger errorCode) {
		JLLog( @"팔로우 실패" );
	}];
}

- (void)userListCell:(UserListCell *)userListCell didTouchFollowingButtonAtIndexPath:(NSIndexPath *)indexPath
{
	User *user = [selectedUserArray objectAtIndex:indexPath.row];
	[self unfollowUser:user success:^{
		
		user.following = NO;
		
		userListCell.followButton.showsActivityIndicatorView = NO;
		[userListCell setUser:user atIndexPath:indexPath];
		
		// 내 프로필을 보고 있을 경우에만
		if( _user.userId == [CurrentUser user].userId )
		{
			_user.followingCount --;
			for( User *following in _following )
			{
				if( following.userId == user.userId )
				{
					[_following removeObject:following];
					break;
				}
			}
			[_tableView reloadData];
		}
		
	} failure:^(NSInteger errorCode) {
		JLLog( @"언팔로우 실패" );
	}];
}


#pragma mark -

- (void)addDish:(Dish *)dish
{
	_user.dishCount ++;
	[_dishes insertObject:dish atIndex:0];
	[_tableView reloadData];
}

- (void)removeDish:(NSInteger)dishId
{
	_user.dishCount --;
	
	for( Dish *dish in _dishes )
	{
		if( dish.dishId == dishId )
		{
			[_dishes removeObject:dish];
			break;
		}
	}
	
	[_tableView reloadData];
}

- (void)addBookmark:(Dish *)dish
{
	_user.bookmarkCount ++;
	[_bookmarks insertObject:dish atIndex:0];
	[_tableView reloadData];
}

- (void)removeBookmark:(NSInteger)dishId
{
	_user.bookmarkCount --;
	
	for( Dish *dish in _bookmarks )
	{
		if( dish.dishId == dishId )
		{
			[_bookmarks removeObject:dish];
			break;
		}
	}
	
	[_tableView reloadData];
}

@end
