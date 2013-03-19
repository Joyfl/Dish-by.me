//
//  MeViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "ProfileViewController.h"
#import "Utils.h"
#import "User.h"
#import "Dish.h"
#import "DishDetailViewController.h"
#import "CurrentUser.h"
#import "DMAPILoader.h"
#import "DMBarButtonItem.h"
#import "AppDelegate.h"
#import "DishTileItem.h"
#import "DMTextFieldViewController.h"
#import "HTBlock.h"

#define isLastDishLoaded ( _dishes.count == _user.dishCount )
#define isLastBookmarkLoaded ( _bookmarks.count == _user.bookmarkCount )
#define selectedDishArray ( _selectedTab == 0 ? _dishes : _bookmarks )
#define userNameWithPlaceholder ( _user.name.length > 0 ? _user.name : NSLocalizedString( @"NO_NAME", nil ) )
#define userBioWithPlaceholder ( _user.bio.length > 0 ? _user.bio : NSLocalizedString( @"NO_BIO", nil ) )


const NSInteger arrowXPositions[] = {36, 110, 185, 260};

@implementation ProfileViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	
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
	
	_dishes = [[NSMutableArray alloc] init];
	_bookmarks = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if( self == [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController] )
	{
		self.navigationItem.leftBarButtonItem = nil;
		self.trackedViewName = @"ProfileViewController (Tab)";
	}
	else
	{
		[DMBarButtonItem setBackButtonToViewController:self];
		self.navigationItem.rightBarButtonItem = nil;
		self.trackedViewName = [[self class] description];
	}
}

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Loading

- (void)loadUserId:(NSInteger)userId
{
	_dishes = [[NSMutableArray alloc] init];
	_bookmarks = [[NSMutableArray alloc] init];
	[_tableView reloadData];
	
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", userId] method:@"GET" parameters:nil success:^(id response) {
		_user = [User userFromDictionary:response];
		[self updateUserPhoto];
		
		self.navigationItem.title = userNameWithPlaceholder;
		
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)loadMoreDishes
{
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _dishes.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/dishes", _user.userId] method:@"GET" parameters:params success:^(id response) {
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

- (void)loadMoreBookmarks
{
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _bookmarks.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/bookmarks", _user.userId] method:@"GET" parameters:params success:^(id response) {
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

- (void)updateUser
{	
	_updating = YES;
	
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", _user.userId] method:@"GET" parameters:nil success:^(id response) {
		_user.userId = [[response objectForKey:@"id"] integerValue];
		_user.name = [response objectForKey:@"name"];
		_user.photoURL = [response objectForKey:@"photo_url"];
		_user.thumbnailURL = [response objectForKey:@"thumbnail_url"];
		_user.bio = [response objectForKey:@"bio"];
		_user.dishCount = [[response objectForKey:@"dish_count"] integerValue];
		_user.bookmarkCount = [[response objectForKey:@"bookmark_count"] integerValue];
		_user.followingCount = [[response objectForKey:@"following_count"] integerValue];
		_user.followersCount = [[response objectForKey:@"followers_count"] integerValue];
		
		self.navigationItem.title = userNameWithPlaceholder;
		
		[self updateDishes];
		[self updateBookmarks];
		
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
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/dishes", _user.userId] method:@"GET" parameters:nil success:^(id response) {
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
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/bookmarks", _user.userId] method:@"GET" parameters:nil success:^(id response) {
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
	[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" image:photo parameters:nil success:^(id response) {
		JLLog( @"Succeed" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)updateUserPhoto
{
	if( _user.photo )
	{
		[_userPhotoButton setBackgroundImage:_user.photo forState:UIControlStateNormal];
	}
	
	else if( _user.thumbnail )
	{
		[_userPhotoButton setBackgroundImage:_user.thumbnail forState:UIControlStateNormal];
	}
	else
	{
		[_userPhotoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
		[[DMAPILoader sharedLoader] loadImageFromURL:[NSURL URLWithString:_user.photoURL] context:nil success:^(UIImage *image, id context) {
			[_userPhotoButton setBackgroundImage:_user.photo = image forState:UIControlStateNormal];
			if( _user.userId == [CurrentUser user].userId )
				[CurrentUser user].photo = image;
		}];
	}
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
	return 2 + ( _selectedTab == 0 ? !isLastDishLoaded : !isLastBookmarkLoaded );
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 ) return 1;
	else if( section == 1 ) return ceil( selectedDishArray.count / 3.0 );
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 ) return 155;
	else if( indexPath.section == 2 ) return 45;
	else if( indexPath.row == ceil( selectedDishArray.count / 3.0 ) - 1 ) return 116;
	return 102;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *profileCellId = @"profileCell";
	static NSString *dishCellId = @"dishCell";
	
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
			nameButton.adjustsImageWhenDisabled = NO;
			[nameButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top.png"] forState:UIControlStateNormal];
			[nameButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top_selected.png"] forState:UIControlStateHighlighted];
			[nameButton addTarget:self action:@selector(nameButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:nameButton];
			
			_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 8, 9, 165, 30 )];
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
			bioButton.adjustsImageWhenDisabled = NO;
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_mid.png"] forState:UIControlStateNormal];
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_mid_selected.png"] forState:UIControlStateHighlighted];
			[bioButton addTarget:self action:@selector(bioButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:bioButton];
			
			_bioLabel = [[UILabel alloc] initWithFrame:CGRectMake( 8, 9, 165, 30 )];
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
				nameButton.enabled = YES;
				
				bioButton.imageEdgeInsets = UIEdgeInsetsMake( 4, 170, 0, 0 );
				[bioButton setImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
				bioButton.enabled = YES;
			}
			else
			{
				nameButton.enabled = NO;
				bioButton.enabled = NO;
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
			_arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
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
		
		return cell;
	}
	
	return nil;
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
			
			_user.thumbnail = image;
			_user.photo = image;
			[self uploadUserPhoto:image];
			[_tableView reloadData];

		}];
		
		[picker setCancelBlock:^(UIImagePickerController *picker) {
			[picker dismissViewControllerAnimated:YES completion:nil];
		}];
		
	}] showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)nameButtonDidTouchUpInside
{
	DMTextFieldViewController *textFieldViewController = [[DMTextFieldViewController alloc] initWithTitle:NSLocalizedString( @"NAME", nil ) completion:^(DMTextFieldViewController *textFieldViewController, NSString *text) {
		_user.name = text;
		[self editUserInfo:@{ @"name": text }];
		self.navigationItem.title = userNameWithPlaceholder;
	}];
	textFieldViewController.trackedViewName = @"DMTextFieldViewController (Name)";
	textFieldViewController.textField.text = _user.name;
	textFieldViewController.textField.placeholder = userNameWithPlaceholder;
	[self.navigationController pushViewController:textFieldViewController animated:YES];
}

- (void)bioButtonDidTouchUpInside
{
	DMTextFieldViewController *textFieldViewController = [[DMTextFieldViewController alloc] initWithTitle:NSLocalizedString( @"BIO", nil ) completion:^(DMTextFieldViewController *textFieldViewController, NSString *text) {
		_user.bio = text;
		[self editUserInfo:@{ @"bio": text }];
		[_tableView reloadData];
	}];
	textFieldViewController.trackedViewName = @"DMTextFieldViewController (Bio)";
	textFieldViewController.textField.text = _user.bio;
	textFieldViewController.textField.placeholder = userBioWithPlaceholder;
	[self.navigationController pushViewController:textFieldViewController animated:YES];
}

- (void)tabDidTouchDown:(UIButton *)button
{
	if( _selectedTab == button.tag )
		_arrowView.image = [UIImage imageNamed:@"arrow_selected.png"];
}

- (void)tabDidTouchUp:(UIButton *)button
{
	_arrowView.image = [UIImage imageNamed:@"arrow.png"];
}

- (void)tabDidTouchUpInside:(UIButton *)button
{
	_selectedTab = button.tag;
	[_tableView reloadData];
}


#pragma mark -
#pragma mark DishListCellDelegate

- (void)dishTileCell:(DishTileCell *)dishTileCell didSelectDishTileItem:(DishTileItem *)dishTileItem
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

@end
