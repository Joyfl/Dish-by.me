//
//  DishViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishViewController.h"
#import "Const.h"
#import "Dish.h"
#import "Utils.h"
#import "DishTileItem.h"

@implementation DishViewController

enum {
	kTokenIdDishes = 0
};

- (id)init
{
    self = [super init];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 480 ) style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:tableView];
	
	dishes = [[NSMutableArray alloc] init];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	NSString *rootUrl = API_ROOT_URL;
	[loader addTokenWithTokenId:0 url:[NSString stringWithFormat:@"%@/dish", rootUrl] method:APILoaderMethodGET params:nil];
	[loader startLoading];
	
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
	if( token.tokenId == kTokenIdDishes )
	{
		NSDictionary *result = [Utils parseJSON:token.data];
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [[Dish alloc] init];
			dish.dishId = [[d objectForKey:@"dish_id"] integerValue];
			dish.userId = [[d objectForKey:@"user_id"] integerValue];
			dish.name = [d objectForKey:@"name"];
			dish.message = [d objectForKey:@"message"];
//			dish.time = [d objectForKey:@"dish_id"];
			dish.yumCount = [[d objectForKey:@"yum_count"] integerValue];
			dish.commentCount = [[d objectForKey:@"comment_count"] integerValue];
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

#define gap 11
#define len 92

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return len + gap;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
	if( cell == nil )
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		for( NSInteger i = 0; i < 3; i++ )
		{			
			if( dishes.count > indexPath.row * 3 + i )
			{
				NSLog( @"i : %d", indexPath.row * 3 + i );
				
				DishTileItem *dishItem = [[DishTileItem alloc] initWithDish:[dishes objectAtIndex:indexPath.row * 3 + i]];
				dishItem.frame = CGRectMake( gap * ( i + 1 ) + len * i, gap, len, len );
				[dishItem setImage:[UIImage imageNamed:@"temp_dish.png"] forState:UIControlStateNormal];
				[cell addSubview:dishItem];
				[dishItem release];
			}
		}
	}
	
	return cell;
}

@end
