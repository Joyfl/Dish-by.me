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
#import "DishTileCell.h"

@implementation DishListViewController

enum {
	kTokenIdDishes = 0
};

- (id)init
{
    self = [super init];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 367 ) style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xEE / 255.0 blue:0xEA / 255.0 alpha:1];
	[self.view addSubview:tableView];
	
	dishes = [[NSMutableArray alloc] init];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	NSString *rootUrl = API_ROOT_URL;
	[loader addTokenWithTokenId:0 url:[NSString stringWithFormat:@"%@/dish", rootUrl] method:APILoaderMethodGET params:nil];
	[loader startLoading];
	
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
	[tableView release];
	[dishes release];
	[loader release];
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
	if( token.tokenId == kTokenIdDishes )
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

- (void)dishItemDidTouchUpInside:(DishTileItem *)dishTileItem
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

@end
