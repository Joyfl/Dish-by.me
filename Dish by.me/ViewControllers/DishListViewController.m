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
#import "ProfileViewController.h"
#import "CurrentUser.h"
#import "UIButton+TouchAreaInsets.h"
#import "AppDelegate.h"

@implementation DishListViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
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
	[_tableView reloadData];
}


#pragma mark -
#pragma mark Loading

- (void)updateDishes
{
	if( _loading )
		return;
	
	JLLog( @"updateDishes" );
	
	_updating = YES;
	_loadedLastDish = NO;
	
	[[DMAPILoader sharedLoader] api:@"/dishes" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		[_dishes removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];
		_offset = data.count;
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)loadMoreDishes
{
	if( _updating )
		return;
	
	JLLog( @"loadMoreDishes" );
	
	_loading = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _offset] };
	[[DMAPILoader sharedLoader] api:@"/dishes" method:@"GET" parameters:params success:^(id response) {
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
	
	ProfileViewController *profileViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController];
	[profileViewController addBookmark:dish];
	
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
	
	ProfileViewController *profileViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController];
	[profileViewController removeBookmark:dish.dishId];
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", dish.dishId];	
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
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
	else if( indexPath.row == _dishes.count - 1 ) return 355;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self showUserPhoto];
	[_scrollTimer invalidate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
	_scrollTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(hideUserPhoto) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:_scrollTimer forMode:NSDefaultRunLoopMode];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	[_scrollTimer invalidate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_scrollTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(hideUserPhoto) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:_scrollTimer forMode:NSDefaultRunLoopMode];
}

- (void)showUserPhoto
{
	for( DishListCell *cell in [_tableView visibleCells] )
	{
		if( cell.indexPath.section == 0 )
		{
			[UIView animateWithDuration:0.25 animations:^{
				cell.topGradientView.alpha = 1;
				cell.userPhotoButton.alpha = 1;
				cell.userNameLabel.alpha = 1;
			}];
		}
	}
}

- (void)hideUserPhoto
{
	for( DishListCell *cell in [_tableView visibleCells] )
	{
		if( cell.indexPath.section == 0 )
		{
			[UIView animateWithDuration:0.25 animations:^{
				cell.topGradientView.alpha = 0;
				cell.userPhotoButton.alpha = 0;
				cell.userNameLabel.alpha = 0;
			}];
		}
	}
}


#pragma mark -
#pragma mark DishListCellDelegate

- (void)dishListCell:(DishListCell *)dishListCell didTouchPhotoViewAtIndexPath:(NSIndexPath *)indexPath
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:[_dishes objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

- (void)dishListCell:(DishListCell *)dishListCell didTouchUserPhotoButtonAtIndexPath:(NSIndexPath *)indexPath
{
	Dish *dish = [_dishes objectAtIndex:indexPath.row];
	
	ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
	[profileViewController loadUserId:dish.userId];
	[self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)dishListCell:(DishListCell *)dishListCell didBookmarkAtIndexPath:(NSIndexPath *)indexPath
{
	[self bookmarkDish:[_dishes objectAtIndex:indexPath.row]];
}

- (void)dishListCell:(DishListCell *)dishListCell didUnbookmarkAtIndexPath:(NSIndexPath *)indexPath
{
	[self unbookmarkDish:[_dishes objectAtIndex:indexPath.row]];
}


#pragma mark -
#pragma mark WritingViewControllerDelegate


@end
