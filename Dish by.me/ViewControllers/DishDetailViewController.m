//
//  DishDetailViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishDetailViewController.h"
#import "Dish.h"
#import "Comment.h"
#import "Const.h"
#import "Utils.h"

@implementation DishDetailViewController

enum {
	kRowPhoto = 0,
	kRowMessage = 1,
	kRowRecipe = 2,
	kRowYum = 3,
};

- (id)initWithDish:(Dish *)_dish
{
	self = [super init];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 367 )];
	tableView.delegate = self;
	tableView.dataSource = self;
//	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:tableView];
	
	dish = [_dish retain];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	NSString *rootURL = API_ROOT_URL;
	NSString *url = [NSString stringWithFormat:@"%@/dish/%d/comment", rootURL, dish.dishId];
	[loader addTokenWithTokenId:0 url:url method:APILoaderMethodGET params:nil];
	[loader startLoading];
	
	comments = [[NSMutableArray alloc] init];
	
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
	if( token.tokenId == 0 )
	{
		NSDictionary *result = [Utils parseJSON:token.data];
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Comment *comment = [[Comment alloc] init];
			comment.userId = [[d objectForKey:@"user_id"] integerValue];
			comment.name = [d objectForKey:@"name"];
			comment.message = [d objectForKey:@"message"];
			[comments addObject:comment];
		}
		
		[tableView reloadData];
	}
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch( section )
	{
		case 0:
			return 4;
			
		case 1:
			return comments.count;
			
		case 2:
			return 1;
	}
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( indexPath.section )
	{
		case 0:
			switch( indexPath.row )
			{
				case kRowPhoto:
					return 320;
					
				case kRowMessage:
					return 100;
					
				case kRowRecipe:
					return 100;
					
				case kRowYum:
					return 100;
			}
			break;
			
		// Comment
		case 1:
			return 50;
		
		// Leave a comment
		case 2:
			return 50;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] init];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if( indexPath.section == 0 )
	{
		if( indexPath.row == kRowPhoto )
		{
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake( 10, 10, 300, 300 )];
			imageView.image = dish.photo;
			
			UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 320 )];
			[bgView addSubview:imageView];
			[imageView release];
			
			cell.backgroundView = bgView;
			[bgView release];
		}
		else if( indexPath.row == kRowMessage )
		{
			cell.textLabel.text = dish.message;
		}
		else if( indexPath.row == kRowRecipe )
		{
			
		}
		else if( indexPath.row == kRowYum )
		{
			cell.textLabel.text = [NSString stringWithFormat:@"%d명이 침을 질질 흘립니다.", dish.yumCount];
		}
	}
	
	// Comments
	else if( indexPath.section == 1 )
	{
		Comment *comment = [comments objectAtIndex:indexPath.row];
		cell.textLabel.text = comment.message;
		cell.detailTextLabel.text = comment.name;
		NSLog( @"comment" );
	}
	
	// Leave comment
	else if( indexPath.section == 2 )
	{
		
	}
	
	return cell;
}

@end
