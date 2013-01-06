//
//  DishViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishListViewController.h"
#import "Const.h"
#import "Dish.h"
#import "Utils.h"
#import "DishTileItem.h"
#import "DishDetailViewController.h"
//#import "DishTileCell.h"
#import "DishListCell.h"

@implementation DishListViewController

enum {
	kRequestIdUpdateDishes = 0,
	kRequestIdLoadMoreDishes = 1,
};

- (id)init
{
    self = [super init];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xEE / 255.0 blue:0xEA / 255.0 alpha:1];
	[self.view addSubview:_tableView];
	
	_dishes = [[NSMutableArray alloc] init];
	
	_loader = [[JLHTTPLoader alloc] init];
	_loader.delegate = self;
	
	self.navigationItem.title = @"Dish by.me";
	
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[_tableView release];
	[_dishes release];
	[_loader release];
}


#pragma mark -
#pragma mark Loading

- (void)updateDishes
{
	JLHTTPGETRequest *req = [[JLHTTPGETRequest alloc] init];
	req.requestId = kRequestIdUpdateDishes;
	req.url = [NSString stringWithFormat:@"%@dishes", API_ROOT_URL];
	[_loader addRequest:req];
	[_loader startLoading];
}

- (void)loadMoreDishes
{
	NSLog( @"[DishListViewController] loadMoreDishes" );
	JLHTTPGETRequest *req = [[JLHTTPGETRequest alloc] init];
	req.requestId = kRequestIdLoadMoreDishes;
	req.url = [NSString stringWithFormat:@"%@dishes", API_ROOT_URL];
	[req setParam:[NSString stringWithFormat:@"%d", _offset] forKey:@"offset"];
	[_loader addRequest:req];
	[_loader startLoading];
}


#pragma mark -
#pragma mark JLHTTPLoaderDelegate

- (void)loader:(JLHTTPLoader *)loader didFinishLoading:(JLHTTPResponse *)response
{
	NSLog( @"body : %@", response.body );
	
	if( response.requestId == kRequestIdUpdateDishes )
	{
		if( response.statusCode == 200 )
		{
			[_dishes removeAllObjects];
			
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
	
	else if( response.requestId == kRequestIdLoadMoreDishes )
	{
		if( response.statusCode == 200 )
		{
			NSDictionary *result = [Utils parseJSON:response.body];
			NSArray *data = [result objectForKey:@"data"];
			_offset += data.count;
			
			for( NSDictionary *d in data )
			{
				Dish *dish = [Dish dishFromDictionary:d];
				[_dishes addObject:dish];
			}
			
			if( data.count == 0 )
				_loadedLastDish = YES;
			
			[_tableView reloadData];
		}
	}
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
			cell = [[DishListCell alloc] initWithReuseIdentifier:cellId];
		
		Dish *dish = [_dishes objectAtIndex:indexPath.row];
		[cell setDish:dish atIndexPath:indexPath];
		[dish release];
		
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
		[indicator release];
		
		if( ![_loader hasRequestId:kRequestIdLoadMoreDishes] )
			[self loadMoreDishes];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:[_dishes objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
	[dishDetailViewController release];
}

@end
