//
//  ForkListViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 13..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "ForkListViewController.h"
#import "DishTileItem.h"
#import "DMBarButtonItem.h"
#import "DishDetailViewController.h"

#define isLastDishLoaded (_dishes.count == _dish.forkCount)

@implementation ForkListViewController

- (id)initWithDish:(Dish *)dish
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	[DMBarButtonItem setBackButtonToViewController:self];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:_tableView];
	
	_dish = dish;
	_dishes = [[NSMutableArray alloc] init];
	
	self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString( @"N_DISHES", @"" ), _dish.forkCount];
	
	return self;
}


#pragma mark -
#pragma mark Loading

- (void)loadForks
{
	_loading = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _dishes.count] };
	[[DMAPILoader sharedLoader] api:[NSString stringWithFormat:@"/dish/%d/forks", _dish.dishId] method:@"GET" parameters:params success:^(id response) {
		NSArray *data = [response objectForKey:@"data"];
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		_loading = NO;
		[_tableView reloadData];
		
		NSLog( @"ASDASDSADSFSADFSuccess" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		_loading = NO;
	}];
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1 + !isLastDishLoaded;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 1 ) return 1;
	return ceil( _dishes.count / 3.0 );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == ceil( _dishes.count / 3.0 ) - 1 ) return 116;
	return 102;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	static NSString *activityIndicatorCellId = @"activityIndicatorCellId";
	
	if( indexPath.section == 0 )
	{
		DishTileCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
		
		if( !cell )
		{
			cell = [[DishTileCell alloc] initWithReuseIdentifier:cellId];
			cell.delegate = self;
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
	else
	{
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
			[self loadForks];
		
		return cell;
	}
}


#pragma mark -
#pragma mark DishTileCellDelegate

- (void)dishTileCell:(DishTileCell *)dishTileCell didSelectDishTileItem:(DishTileItem *)dishTileItem
{
	DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

@end
