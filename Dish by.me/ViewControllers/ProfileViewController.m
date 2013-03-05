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
#import "DishByMeAPILoader.h"

#define ARROW_LEFT_X	142
#define ARROW_RIGHT_X	248


@implementation ProfileViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:_tableView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake( 0, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height )];
	_refreshHeaderView.delegate = self;
	_refreshHeaderView.backgroundColor = self.view.backgroundColor;
	[_tableView addSubview:_refreshHeaderView];
	
	_dishes = [[NSMutableArray alloc] init];
	_bookmarks = [[NSMutableArray alloc] init];
	
	self.navigationItem.title = @"Dish by.me";
	
	return self;
}

- (void)setUserId:(NSInteger)userId
{
	_userId = userId;
	[self loadUserId:userId];
}

- (void)loadUserId:(NSInteger)userId
{
	[[DishByMeAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", userId] method:@"GET" parameters:nil success:^(id response) {
		_user = [User userFromDictionary:response];
		self.navigationItem.title = _user.name;
		
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)updateUser
{
	_loadedLastDish = NO;
	_loadedLastBookmark = NO;
	[_dishes removeAllObjects];
	[_bookmarks removeAllObjects];
	_dishOffset = _bookmarkOffset = 0;
	
	_updating = YES;
	
	[[DishByMeAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d", _user.userId] method:@"GET" parameters:nil success:^(id response) {
		_user = [User userFromDictionary:response];
		self.navigationItem.title = _user.name;
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)loadDishes
{
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _dishOffset] };
	[[DishByMeAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/dishes", _user.userId] method:@"GET" parameters:params success:^(id response) {
		NSArray *data = [response objectForKey:@"data"];
		_dishOffset += data.count;
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		if( data.count == 0 )
			_loadedLastDish = YES;
		
		if( _selectedTab == 0 )
			[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)loadBookmarks
{
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _bookmarkOffset] };
	[[DishByMeAPILoader sharedLoader] api:[NSString stringWithFormat:@"/user/%d/bookmarks", _user.userId] method:@"GET" parameters:params success:^(id response) {
		NSArray *data = [response objectForKey:@"data"];
		_bookmarkOffset += data.count;
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_bookmarks addObject:dish];
		}
		
		if( data.count == 0 )
			_loadedLastBookmark = YES;
		
		if( _selectedTab == 1 )
			[_tableView reloadData];
		
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
	[[DishByMeAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
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
	[[DishByMeAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
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
	return 2 + ( _selectedTab == 0 ? !_loadedLastDish : !_loadedLastBookmark );
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 ) return 1;
	else if( section == 1 ) return _selectedTab == 0 ? _dishes.count : _bookmarks.count;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 ) return 105;
	else if( indexPath.section == 2 ) return 45;
	else if( _selectedTab == 0 && indexPath.row == _dishes.count - 1 ) return 355;
	else if( _selectedTab == 1 && indexPath.row == _bookmarks.count - 1 ) return 355;
	return 345;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *profileCellId = @"profileCell";
	static NSString *dishCellId = @"dishCell";
	static NSString *bookmarkCellId = @"bookmarkCell";
	
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
			
			_profileImage = [[UIButton alloc] initWithFrame:CGRectMake( 14, 14, 85, 86 )];
			[cell addSubview:_profileImage];
			
			UIImageView *profileBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_border.png"]];
			profileBorder.frame = CGRectMake( 10, 10, 93, 94 );
			[cell addSubview:profileBorder];
			
			UIButton *bioButton = [[UIButton alloc] initWithFrame:CGRectMake( 103, 10, 211, 47 )];
			bioButton.titleLabel.font = [UIFont systemFontOfSize:13];
			bioButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top.png"] forState:UIControlStateNormal];
			
			// My profile
			if( _user.userId == [[UserManager manager] userId] )
			{
				bioButton.imageEdgeInsets = UIEdgeInsetsMake( 4, 170, 0, 0 );
				[bioButton setImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
				bioButton.enabled = YES;
			}
			else
			{
				bioButton = NO; // ???????
			}
			
			_bioLabel = [[UILabel alloc] initWithFrame:CGRectMake( 10, 10, 165, 30 )];
			_bioLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			_bioLabel.font = [UIFont systemFontOfSize:13];
			_bioLabel.backgroundColor = [UIColor clearColor];
			_bioLabel.numberOfLines = 2;
			[bioButton addSubview:_bioLabel];
			
			[cell addSubview:bioButton];
			
			UIButton *dishButton = [[UIButton alloc] initWithFrame:CGRectMake( 103, 57, 104, 47 )];
			[dishButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_left.png"] forState:UIControlStateNormal];
			[dishButton addTarget:self action:@selector(dishButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:dishButton];
			
			_dishCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 4, 94, 20 )];
			_dishCountLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1];
			_dishCountLabel.textAlignment = NSTextAlignmentCenter;
			_dishCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_dishCountLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:_dishCountLabel];
			
			_dishLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 20, 94, 20 )];
			_dishLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			_dishLabel.textAlignment = NSTextAlignmentCenter;
			_dishLabel.font = [UIFont systemFontOfSize:13];
			_dishLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:_dishLabel];
			
			UIButton *bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake( 207, 57, 107, 47 )];
			[bookmarkButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_right.png"] forState:UIControlStateNormal];
			[bookmarkButton addTarget:self action:@selector(bookmarkButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:bookmarkButton];
			
			_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 4, 97, 20 )];
			_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _user.bookmarkCount];
			_bookmarkCountLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1];
			_bookmarkCountLabel.textAlignment = NSTextAlignmentCenter;
			_bookmarkCountLabel.font = [UIFont boldSystemFontOfSize:20];
			_bookmarkCountLabel.backgroundColor = [UIColor clearColor];
			[bookmarkButton addSubview:_bookmarkCountLabel];
			
			_bookmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 20, 97, 20 )];
			_bookmarkLabel.text = NSLocalizedString( @"BOOKMARKS", @"" );
			_bookmarkLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			_bookmarkLabel.textAlignment = NSTextAlignmentCenter;
			_bookmarkLabel.font = [UIFont systemFontOfSize:13];
			_bookmarkLabel.backgroundColor = [UIColor clearColor];
			[bookmarkButton addSubview:_bookmarkLabel];
			
			_arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
			_arrowView.frame = CGRectMake( ARROW_LEFT_X, 101, 25, 11 );
			[cell addSubview:_arrowView];
		}
		
		[[DishByMeAPILoader sharedLoader] loadImageFromURL:[NSURL URLWithString:_user.photoURL] context:nil success:^(UIImage *image, id context) {
			[_profileImage setBackgroundImage:_user.photo = image forState:UIControlStateNormal];
		}];
		
		_bioLabel.text = _user.bio;
		_dishCountLabel.text = [NSString stringWithFormat:@"%d", _user.dishCount];
		_dishLabel.text = NSLocalizedString( @"DISHES", @"" );
		
		return cell;
	}
	
	else if( indexPath.section == 1 )
	{
		DishListCell *cell = nil;
		
		//
		// Dishes
		//
		if( _selectedTab == 0 )
		{
			cell = [tableView dequeueReusableCellWithIdentifier:dishCellId];
			
			if( !cell )
			{
				cell = [[DishListCell alloc] initWithReuseIdentifier:dishCellId];
				cell.delegate = self;
			}
			
			Dish *dish = [_dishes objectAtIndex:indexPath.row];
			[cell setDish:dish atIndexPath:indexPath];
		}
		
		//
		// Bookmarks
		//
		else
		{
			cell = [_tableView dequeueReusableCellWithIdentifier:bookmarkCellId];
			
			if( !cell )
			{
				cell = [[DishListCell alloc] initWithReuseIdentifier:bookmarkCellId];
				cell.delegate = self;
			}
			
			Dish *dish = [_bookmarks objectAtIndex:indexPath.row];
			[cell setDish:dish atIndexPath:indexPath];
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
			[self loadDishes];
		
		else if( !_loadingBookmarks && _selectedTab == 1 )
			[self loadBookmarks];
		
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

- (void)dishButtonDidTouchUpInside
{
	_selectedTab = 0;
	[_tableView reloadData];
	
	CGRect frame = _arrowView.frame;
	frame.origin.x = ARROW_LEFT_X;
	_arrowView.frame = frame;
}

- (void)bookmarkButtonDidTouchUpInside
{
	_selectedTab = 1;
	[_tableView reloadData];
	
	CGRect frame = _arrowView.frame;
	frame.origin.x = ARROW_RIGHT_X;
	_arrowView.frame = frame;
}


#pragma mark -
#pragma mark DishListCellDelegate

- (void)dishListCell:(DishListCell *)dishListCell didTouchPhotoViewAtIndexPath:(NSIndexPath *)indexPath
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:[_dishes objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

- (void)dishListCell:(DishListCell *)dishListCell didBookmarkAtIndexPath:(NSIndexPath *)indexPath
{
	[self bookmarkDish:[_dishes objectAtIndex:indexPath.row]];
}

- (void)dishListCell:(DishListCell *)dishListCell didUnbookmarkAtIndexPath:(NSIndexPath *)indexPath
{
	[self unbookmarkDish:[_dishes objectAtIndex:indexPath.row]];
}

@end
