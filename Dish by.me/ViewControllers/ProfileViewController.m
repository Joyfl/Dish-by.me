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
#import "UserManager.h"
#import "DMAPILoader.h"
#import "DMBarButtonItem.h"
#import "AppDelegate.h"
#import "DishTileItem.h"
#import "DMTextFieldViewController.h"


#define ARROW_LEFT_X	140
#define ARROW_RIGHT_X	246

#define isLastDishLoaded ( _dishes.count == _user.dishCount )
#define isLastBookmarkLoaded ( _bookmarks.count == _user.bookmarkCount )
#define selectedDishArray ( _selectedTab == 0 ? _dishes : _bookmarks )
#define userNameWithPlaceholder ( _user.name.length > 0 ? _user.name : NSLocalizedString( @"NO_NAME", nil ) )
#define userBioWithPlaceholder ( _user.bio.length > 0 ? _user.bio : NSLocalizedString( @"NO_BIO", nil ) )

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
		self.navigationItem.rightBarButtonItem = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"EDIT", nil ) target:self action:@selector(nameEditButtonHandler)];
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
#pragma mark Setter

- (void)setUserId:(NSInteger)userId
{
	_userId = userId;
	[self loadUserId:userId];
}


#pragma mark -
#pragma mark Loading

- (void)loadUserId:(NSInteger)userId
{
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", userId] method:@"GET" parameters:nil success:^(id response) {
		_user = [User userFromDictionary:response];
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
	if( indexPath.section == 0 ) return 110;
	else if( indexPath.section == 2 ) return 45;
	else if( indexPath.row == ceil( selectedDishArray.count / 3.0 ) - 1 ) return 116;
//	else if( _selectedTab == 0 && indexPath.row == _dishes.count - 1 ) return 112;
//	else if( _selectedTab == 1 && indexPath.row == _bookmarks.count - 1 ) return 112;
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
			
			_profileImage = [[UIButton alloc] initWithFrame:CGRectMake( 12, 13, 85, 86 )];
			[cell addSubview:_profileImage];
			
			UIImageView *profileBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_border.png"]];
			profileBorder.frame = CGRectMake( 8, 9, 93, 94 );
			[cell addSubview:profileBorder];
			
			UIButton *bioButton = [[UIButton alloc] initWithFrame:CGRectMake( 101, 9, 211, 47 )];
			bioButton.titleLabel.font = [UIFont systemFontOfSize:13];
			bioButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			bioButton.adjustsImageWhenHighlighted = NO;
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top.png"] forState:UIControlStateNormal];
			[bioButton addTarget:self action:@selector(bioButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			
			// My profile
			if( _user.userId == [[UserManager manager] userId] )
			{
				bioButton.imageEdgeInsets = UIEdgeInsetsMake( 4, 170, 0, 0 );
				[bioButton setImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
				bioButton.enabled = YES;
			}
			
			_bioLabel = [[UILabel alloc] initWithFrame:CGRectMake( 8, 9, 165, 30 )];
			_bioLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			_bioLabel.font = [UIFont systemFontOfSize:13];
			_bioLabel.backgroundColor = [UIColor clearColor];
			_bioLabel.numberOfLines = 2;
			[bioButton addSubview:_bioLabel];
			
			[cell addSubview:bioButton];
			
			UIButton *dishButton = [[UIButton alloc] initWithFrame:CGRectMake( 101, 56, 104, 47 )];
			[dishButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_left.png"] forState:UIControlStateNormal];
			[dishButton addTarget:self action:@selector(dishButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			dishButton.adjustsImageWhenHighlighted = NO;
			[cell addSubview:dishButton];
			
			_dishCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 3, 5, 94, 20 )];
			_dishCountLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			_dishCountLabel.textAlignment = NSTextAlignmentCenter;
			_dishCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_dishCountLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:_dishCountLabel];
			
			_dishLabel = [[UILabel alloc] initWithFrame:CGRectMake( 3, 21, 94, 20 )];
			_dishLabel.text = NSLocalizedString( @"DISHES", @"" );
			_dishLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			_dishLabel.textAlignment = NSTextAlignmentCenter;
			_dishLabel.font = [UIFont systemFontOfSize:13];
			_dishLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:_dishLabel];
			
			UIButton *bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake( 205, 56, 107, 47 )];
			[bookmarkButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_right.png"] forState:UIControlStateNormal];
			[bookmarkButton addTarget:self action:@selector(bookmarkButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			bookmarkButton.adjustsImageWhenHighlighted = NO;
			[cell addSubview:bookmarkButton];
			
			_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 3, 5, 97, 20 )];
			_bookmarkCountLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			_bookmarkCountLabel.textAlignment = NSTextAlignmentCenter;
			_bookmarkCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_bookmarkCountLabel.backgroundColor = [UIColor clearColor];
			[bookmarkButton addSubview:_bookmarkCountLabel];
			
			_bookmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake( 3, 21, 97, 20 )];
			_bookmarkLabel.text = NSLocalizedString( @"BOOKMARKS", @"" );
			_bookmarkLabel.textColor = [UIColor colorWithHex:0x6B6663 alpha:1];
			_bookmarkLabel.textAlignment = NSTextAlignmentCenter;
			_bookmarkLabel.font = [UIFont systemFontOfSize:13];
			_bookmarkLabel.backgroundColor = [UIColor clearColor];
			[bookmarkButton addSubview:_bookmarkLabel];
			
			_arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
			[cell addSubview:_arrowView];
		}
		
		[[DMAPILoader sharedLoader] loadImageFromURL:[NSURL URLWithString:_user.photoURL] context:nil success:^(UIImage *image, id context) {
			[_profileImage setBackgroundImage:_user.photo = image forState:UIControlStateNormal];
		}];
		
		_bioLabel.text = userBioWithPlaceholder;
		_dishCountLabel.text = [NSString stringWithFormat:@"%d", _user.dishCount];
		_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _user.bookmarkCount];
		_arrowView.frame = CGRectMake( _selectedTab == 0 ? ARROW_LEFT_X : ARROW_RIGHT_X, 100, 25, 11 );
		
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

- (void)nameEditButtonHandler
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

- (void)dishButtonDidTouchUpInside
{
	_selectedTab = 0;
	[_tableView reloadData];
}

- (void)bookmarkButtonDidTouchUpInside
{
	_selectedTab = 1;
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
