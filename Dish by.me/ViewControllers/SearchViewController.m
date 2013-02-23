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
#import "DishTileItem.h"
#import "DishTileCell.h"
#import "DMButton.h"
#import "DishDetailViewController.h"

@implementation SearchViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
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
	[_searchBar addSubview:_searchInput];
	
	DMButton *searchButton = [[DMButton alloc] initWithTitle:NSLocalizedString( @"SEARCH", @"" )];
	searchButton.frame = CGRectMake( 250, 5, 60, 30 );
	searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[searchButton addTarget:self action:@selector(searchButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_searchBar addSubview:searchButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 45, 320, 322 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:_tableView];
	
	_dishes = [[NSMutableArray alloc] init];
	
	_loader = [[JLHTTPLoader alloc] init];
	_loader.delegate = self;
	
	self.navigationItem.title = @"Dish by.me";
	
    return self;
}


#pragma mark -
#pragma mark JLHTTPLoaderDelegate

- (BOOL)shouldLoadWithrequest:(JLHTTPRequest *)request
{
	return YES;
}

- (void)loaderDidFinishLoading:(JLHTTPResponse *)response
{
	//	NSLog( @"%@", request.data );
	
	if( response.requestId == 0 )
	{
		NSDictionary *result = [Utils parseJSON:response.body];
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		[_tableView reloadData];
	}
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ceil( _dishes.count / 3.0 );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return DISH_TILE_LEN + DISH_TILE_GAP;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	DishTileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if( !cell )
	{
		cell = [[DishTileCell alloc] initWithReuseIdentifier:cellId target:self action:@selector(dishItemDidTouchUpInside:)];
	}
	
	for( NSInteger i = 0; i < 3; i++ )
	{
		DishTileItem *dishItem = [cell dishItemAt:i];
		
		if( _dishes.count > indexPath.row * 3 + i )
		{
			dishItem.hidden = NO;
			
			Dish *dish = [_dishes objectAtIndex:indexPath.row * 3 + i];
			dishItem.dish = dish;
		}
		else
		{
			dishItem.hidden = YES;
		}
	}
	
	return cell;
}


#pragma mark -
#pragma mark Selectors

- (void)searchButtonDidTouchUpInside
{
	[_dishes removeAllObjects];
	[_tableView reloadData];
	
	[_searchInput resignFirstResponder];
	
	NSString *rootUrl = API_ROOT_URL;
//	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_searchInput.text, @"query", nil];
//	[_loader addRequestWithRequestId:0 url:[NSString stringWithFormat:@"%@/search", rootUrl] method: params:params];
	[_loader startLoading];
}

- (void)dishItemDidTouchUpInside:(DishTileItem *)dishTileItem
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

@end
