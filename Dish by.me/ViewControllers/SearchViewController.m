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
#import "DishByMeAPILoader.h"

@implementation SearchViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	_searchBar = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 45 )];
	[self.view addSubview:_searchBar];
	
	UIImageView *searchBarBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"]];
	[_searchBar addSubview:searchBarBg];
	
	UIImageView *searchInputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield_bg.png"]];
	searchInputBg.frame = CGRectMake( 5, 5, 235, 30 );
	[_searchBar addSubview:searchInputBg];
	
	_searchInput = [[UITextField alloc] initWithFrame:CGRectMake( 12, 11, 230, 20 )];
	_searchInput.font = [UIFont systemFontOfSize:13];
	_searchInput.placeholder = NSLocalizedString( @"SEARCH_INPUT", @"" );
	[_searchInput addTarget:self action:@selector(searchInputEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
	[_searchBar addSubview:_searchInput];
	
	DMButton *searchButton = [[DMButton alloc] initWithTitle:NSLocalizedString( @"SEARCH", @"" )];
	searchButton.frame = CGRectMake( 250, 5, 60, 30 );
	searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[searchButton addTarget:self action:@selector(searchButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_searchBar addSubview:searchButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 45, 320, UIScreenHeight - 158 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:_tableView];
	
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
#pragma mark Loading

- (void)search:(NSString *)query
{
	JLLog( @"search" );
	if( !query ) return;
	
	_searching = YES;
	
	NSDictionary *params = @{ @"query": query, @"offset": [NSString stringWithFormat:@"%d", _dishes.count] };
	[[DishByMeAPILoader sharedLoader] api:@"/search" method:@"GET" parameters:params success:^(id response) {		
		_count = [[response objectForKey:@"count"] integerValue];
		NSArray *data = [response objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		_lastQuery = query;
		
		_searching = NO;
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


#pragma mark -
#pragma mark SearchInput

- (void)searchInputEditingDidBegin
{
	[UIView animateWithDuration:0.25 animations:^{
		_dimView.alpha = 0.7;
	}];
}


#pragma mark -
#pragma mark Selectors

- (void)searchButtonDidTouchUpInside
{
	[_dishes removeAllObjects];
	[_tableView reloadData];
	[self dimViewDidTap];
	
	[self search:_searchInput.text];
}

- (void)dimViewDidTap
{
	[_searchInput resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		_dimView.alpha = 0;
	}];
}

@end
