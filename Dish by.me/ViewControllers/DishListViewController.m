//
//  DishViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishListViewController.h"
#import "Dish.h"
#import "DishTileItem.h"
#import "DishDetailViewController.h"
#import "UserManager.h"

@implementation DishListViewController

enum {
	kRequestIdUpdateDishes = 0,
	kRequestIdLoadMoreDishes = 1,
	kRequestIdBookmark = 2,
	kRequestIdUnbookmark = 3,
};

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:_tableView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake( 0, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height )];
	_refreshHeaderView.delegate = self;
	_refreshHeaderView.backgroundColor = self.view.backgroundColor;
	[_tableView addSubview:_refreshHeaderView];
	
	_dishes = [[NSMutableArray alloc] init];
	
	self.navigationItem.title = @"Dish by.me";
	
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
//	[self updateDishes];
	[_tableView reloadData];
}


#pragma mark -
#pragma mark Loading

- (void)updateDishes
{
	JLLog( @"updateDishes" );
	
	_updating = YES;
	
	[[DishByMeAPILoader sharedLoader] api:@"/dishes" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		[_dishes removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		[_tableView reloadData];
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
		_updating = NO;
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_updating = NO;
	}];
}

- (void)loadMoreDishes
{
	JLLog( @"loadMoreDishes" );
	
	_loading = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _offset] };
	[[DishByMeAPILoader sharedLoader] api:@"/dishes" method:@"GET" parameters:params success:^(id response) {
		JLLog( @"Success" );
		
		NSArray *data = [response objectForKey:@"data"];
		_offset += data.count;
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		if( data.count == 0 )
			_loadedLastDish = YES;
		
		[_tableView reloadData];
		
		_loading = NO;
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_loading = NO;
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
	[self updateDishes];
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
	return 1 + !_loadedLastDish;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 1 ) return 1;
	return _dishes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 1 ) return 45;
	if( indexPath.row == _dishes.count - 1 ) return 355;
	return 345;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	
	if( indexPath.section == 0 )
	{
		DishListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if( !cell )
		{
			cell = [[DishListCell alloc] initWithReuseIdentifier:cellId];
			cell.delegate = self;
		}
		
		Dish *dish = [_dishes objectAtIndex:indexPath.row];
		[cell setDish:dish atIndexPath:indexPath];
		
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
		
		if( !_loading )
			[self loadMoreDishes];
		
		return cell;
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
