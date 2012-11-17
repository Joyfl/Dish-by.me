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
#import "DishByMeButton.h"
#import "DishDetailViewController.h"

@implementation SearchViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	searchBar = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 45 )];
	[self.view addSubview:searchBar];
	
	UIImageView *searchBarBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"]];
	[searchBar addSubview:searchBarBg];
	[searchBarBg release];
	
	UIImageView *searchInputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield_bg.png"]];
	searchInputBg.frame = CGRectMake( 5, 5, 235, 30 );
	[searchBar addSubview:searchInputBg];
	[searchInputBg release];
	
	searchInput = [[UITextField alloc] initWithFrame:CGRectMake( 12, 11, 230, 20 )];
	searchInput.font = [UIFont systemFontOfSize:13];
	searchInput.placeholder = NSLocalizedString( @"SEARCH_INPUT", @"" );
	[searchBar addSubview:searchInput];
	
	DishByMeButton *searchButton = [[DishByMeButton alloc] initWithTitle:NSLocalizedString( @"SEARCH", @"" )];
	searchButton.frame = CGRectMake( 250, 5, 60, 30 );
	searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[searchButton addTarget:self action:@selector(searchButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[searchBar addSubview:searchButton];
	[searchButton release];
	
	[searchBar release];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 45, 320, 322 ) style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:tableView];
	
	dishes = [[NSMutableArray alloc] init];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	self.navigationItem.title = @"Dish by.me";
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark APILoaderDelegate

- (BOOL)shouldLoadWithToken:(APILoaderToken *)token
{
	return YES;
}

- (void)loadingDidFinish:(APILoaderToken *)token
{
//	NSLog( @"%@", token.data );
	
	if( token.tokenId == 0 )
	{
		NSDictionary *result = [Utils parseJSON:token.data];
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [[Dish alloc] initWithDictionary:d];
			[dishes addObject:dish];
			[dish release];
		}
		
		[tableView reloadData];
	}
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ceil( dishes.count / 3.0 );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return DISH_TILE_LEN + DISH_TILE_GAP;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	DishTileCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
	
	if( !cell )
	{
		cell = [[DishTileCell alloc] initWithReuseIdentifier:cellId target:self action:@selector(dishItemDidTouchUpInside:)];
	}
	
	for( NSInteger i = 0; i < 3; i++ )
	{
		DishTileItem *dishItem = [cell dishItemAt:i];
		
		if( dishes.count > indexPath.row * 3 + i )
		{
			dishItem.hidden = NO;
			
			Dish *dish = [dishes objectAtIndex:indexPath.row * 3 + i];
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
	[dishes removeAllObjects];
	[tableView reloadData];
	
	[searchInput resignFirstResponder];
	
	NSString *rootUrl = API_ROOT_URL;
	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:searchInput.text, @"query", nil];
	[loader addTokenWithTokenId:0 url:[NSString stringWithFormat:@"%@/search", rootUrl] method:APILoaderMethodGET params:params];
	[loader startLoading];
}

- (void)dishItemDidTouchUpInside:(DishTileItem *)dishTileItem
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

@end
