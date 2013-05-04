//
//  SearchViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "SearchViewController.h"
#import "Utils.h"
#import "Dish.h"
#import "DMButton.h"
#import "DishDetailViewController.h"
#import "DMAPILoader.h"
#import "ProfileViewController.h"

@implementation SearchViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	UIImageView *searchBarBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"]];
	[self.view addSubview:searchBarBackgroundView];
	
	_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake( 2, 0, 316, 45 )];
	_searchBar.delegate = self;
	_searchBar.backgroundImage = [[UIImage alloc] init];
	[_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bar_textfield.png"] forState:UIControlStateNormal];
	_searchBar.placeholder = NSLocalizedString( @"SEARCH", nil );
	_searchBar.searchTextPositionAdjustment = UIOffsetMake( 0, -1 );
	
	_searchButton = [[UIButton alloc] initWithFrame:CGRectMake( -8, -1, 51, 31 )];
	_searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	_searchButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_searchButton setTitle:NSLocalizedString( @"SEARCH", nil ) forState:UIControlStateNormal];
	[_searchButton setTitleColor:[UIColor colorWithHex:0x828083 alpha:1] forState:UIControlStateNormal];
	[_searchButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
	[_searchButton setBackgroundImage:[UIImage imageNamed:@"button_search.png"] forState:UIControlStateNormal];
	[_searchButton setBackgroundImage:[UIImage imageNamed:@"button_search_selected.png"] forState:UIControlStateHighlighted];
	[_searchButton addTarget:self action:@selector(searchButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 45, 320, UIScreenHeight - 158 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:_tableView];
	
	_messageLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, UIScreenWidth, 0 )];
	_messageLabel.font = [UIFont boldSystemFontOfSize:15];
	_messageLabel.numberOfLines = 0;
	_messageLabel.textAlignment = NSTextAlignmentCenter;
	_messageLabel.backgroundColor = [UIColor clearColor];
	_messageLabel.textColor = [UIColor colorWithHex:0x717374 alpha:1];
	_messageLabel.shadowColor = [UIColor whiteColor];
	_messageLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_tableView addSubview:_messageLabel];
	[self.view addSubview:_searchBar];
	
	_dimView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 45, 320, UIScreenHeight )];
	_dimView.userInteractionEnabled = YES;
	_dimView.backgroundColor = [UIColor blackColor];
	_dimView.alpha = 0;
	[self.view addSubview:_dimView];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewDidTap)];
	[_dimView addGestureRecognizer:tapRecognizer];
	
	_dishes = [[NSMutableArray alloc] init];
	
	self.navigationItem.title = @"Dish by.me";
	
    return self;
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[_searchBar setShowsCancelButton:YES animated:YES];
	
	for( UIView *cancelButton in _searchBar.subviews )
	{
		if( [[cancelButton.class description] isEqualToString:@"UINavigationButton"] )
		{
			for( UIView *subview in cancelButton.subviews )
			{
				[subview removeFromSuperview];
			}
			
			[cancelButton addSubview:_searchButton];
		}
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		_dimView.alpha = 0.7;
	}];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self searchButtonDidTouchUpInside];
}

- (void)searchButtonDidTouchUpInside
{
	if( _searchBar.text.length == 0 )
		return;
	
	[_dishes removeAllObjects];
	[_tableView reloadData];
	[self dimViewDidTap];
	
	[self search:_searchBar.text];
}

- (void)dimViewDidTap
{
	[_searchBar resignFirstResponder];
	[_searchBar setShowsCancelButton:NO animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^{
		_dimView.alpha = 0;
	}];
}


#pragma mark -
#pragma mark Loading

- (void)search:(NSString *)query
{
	JLLog( @"search" );
	if( !query ) return;
	
	_searching = YES;
	_messageLabel.hidden = YES;
	_tableView.contentInset = UIEdgeInsetsMake( 0, 0, 0, 0 );
	
	NSDictionary *params = @{ @"query": query, @"offset": [NSString stringWithFormat:@"%d", _dishes.count] };
	[[DMAPILoader sharedLoader] api:@"/search" method:@"GET" parameters:params success:^(id response) {		
		_count = [[response objectForKey:@"count"] integerValue];
		NSArray *data = [response objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		_lastQuery = query;
		
		_searching = NO;
		_messageLabel.hidden = NO;
		
		if( data.count == 0 )
		{
			_messageLabel.text = NSLocalizedString( @"NO_SEARCH_RESULT", nil );
			[_messageLabel sizeToFit];
			_messageLabel.frame = CGRectMake( 0, 147, 320, _messageLabel.frame.size.height );
		}
		else
		{
			_tableView.contentInset = UIEdgeInsetsMake( 40, 0, 0, 0 );
			_messageLabel.text = [NSString stringWithFormat:NSLocalizedString( _count == 1 ? @"ONE_DISH_WAS_FOUND" : @"N_DISHES_WERE_FOUND", nil ), _count];
			[_messageLabel sizeToFit];
			_messageLabel.frame = CGRectMake( 0, -28, 320, _messageLabel.frame.size.height );
		}
		
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		_searching = NO;
		
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


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1 + (_dishes.count != _count);
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
		
		if( !_searching )
			[self search:_lastQuery];
		
		return cell;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self showUserPhoto];
	[_scrollTimer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
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

@end
