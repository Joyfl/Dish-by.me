//
//  MeViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "ProfileViewController.h"
#import "Const.h"
#import "Utils.h"
#import "User.h"
#import "Dish.h"
#import "DishTileItem.h"

#define ARROW_LEFT_X	142
#define ARROW_RIGHT_X	248

@implementation ProfileViewController

enum {
	kTokenIdUser = 0,
	kTokenIdDishes = 1,
	kTokenIdLikes = 2
};

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 367 )];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	[self.view addSubview:tableView];
	
	dishes = [[NSMutableArray alloc] init];
	likes = [[NSMutableArray alloc] init];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	tmpUserId = 1;
	
	NSString *rootUrl = API_ROOT_URL;
#warning 임시 user_id
	[loader addTokenWithTokenId:kTokenIdUser url:[NSString stringWithFormat:@"%@/user/%d", rootUrl, tmpUserId] method:APILoaderMethodGET params:nil];
#warning 임시 user_id
	[loader addTokenWithTokenId:kTokenIdDishes url:[NSString stringWithFormat:@"%@/user/%d/dish", rootUrl, tmpUserId] method:APILoaderMethodGET params:nil];
#warning 임시 user_id
	[loader addTokenWithTokenId:kTokenIdLikes url:[NSString stringWithFormat:@"%@/user/%d/yum", rootUrl, tmpUserId] method:APILoaderMethodGET params:nil];
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
	NSDictionary *result = [Utils parseJSON:token.data];
	
	if( token.tokenId == kTokenIdUser )
	{
		user = [[User alloc] init];
		user.userId = [[result objectForKey:@"user_id"] integerValue];
		user.name = [result objectForKey:@"user_name"];
		user.bio =[result objectForKey:@"bio"];
		user.dishCount = [[result objectForKey:@"dish_count"] integerValue];
		user.yumCount = [[result objectForKey:@"yum_count"] integerValue];
		
		self.navigationItem.title = user.name;
		
		dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
			NSString *rootURL = WEB_ROOT_URL;
			NSString *url = [NSString stringWithFormat:@"%@/images/original/profile/%d.jpg", rootURL, user.userId];
			NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
			if( data == nil )
				return;
			
			dispatch_async( dispatch_get_main_queue(), ^{
				user.photo = [UIImage imageWithData:data];
			} );
			
			[data release];
		});
	}
	
	else if( token.tokenId == kTokenIdDishes )
	{
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [[Dish alloc] init];
			dish.dishId = [[d objectForKey:@"dish_id"] integerValue];
			dish.dishName = [d objectForKey:@"dish_name"];
			dish.userId = [[d objectForKey:@"user_id"] integerValue];
			dish.userName = [d objectForKey:@"user_name"];
			dish.message = [d objectForKey:@"message"];
//			dish.time = [d objectForKey:@"dish_id"];
			dish.hasRecipe = [[d objectForKey:@"has_recipe"] boolValue];
			if( dish.hasRecipe )
				dish.recipe = [d objectForKey:@"recipe"];
			dish.yumCount = [[d objectForKey:@"yum_count"] integerValue];
			dish.commentCount = [[d objectForKey:@"comment_count"] integerValue];
			[dishes addObject:dish];
			[dish release];
		}
		
		[tableView reloadData];
	}
	
	else if( token.tokenId == kTokenIdLikes )
	{
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [[Dish alloc] init];
			dish.dishId = [[d objectForKey:@"dish_id"] integerValue];
			dish.dishName = [d objectForKey:@"dish_name"];
			dish.userId = [[d objectForKey:@"user_id"] integerValue];
			dish.userName = [d objectForKey:@"user_name"];
			dish.message = [d objectForKey:@"message"];
//			dish.time = [d objectForKey:@"dish_id"];
			dish.hasRecipe = [[d objectForKey:@"has_recipe"] boolValue];
			if( dish.hasRecipe )
				dish.recipe = [d objectForKey:@"recipe"];
			dish.yumCount = [[d objectForKey:@"yum_count"] integerValue];
			dish.commentCount = [[d objectForKey:@"comment_count"] integerValue];
			[likes addObject:dish];
			[dish release];
		}
		
		[tableView reloadData];
	}
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 )
		return 1;
	
	return selectedTab == 0 ? ceil( dishes.count / 3.0 ) : ceil( likes.count / 3.0 );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 )
		return 105;
	
	return DISH_TILE_LEN + DISH_TILE_GAP;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *profileCellId = @"profileCell";
	static NSString *dishCellId = @"dishCell";
	static NSString *likeCellId = @"likeCell";
	
	if( indexPath.section == 0 )
	{
		UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:profileCellId];
		if( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			profileImage = [[UIButton alloc] initWithFrame:CGRectMake( 14, 14, 85, 86 )];
			[profileImage setBackgroundImage:user.photo forState:UIControlStateNormal];
			[cell addSubview:profileImage];
			
			UIImageView *profileBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_border.png"]];
			profileBorder.frame = CGRectMake( 10, 10, 93, 94 );
			[cell addSubview:profileBorder];
			[profileBorder release];
			
			UIButton *bioButton = [[UIButton alloc] initWithFrame:CGRectMake( 103, 10, 211, 47 )];
			bioButton.titleLabel.font = [UIFont systemFontOfSize:13];
			bioButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top.png"] forState:UIControlStateNormal];
			
#warning 임시 user_id(1)
			// My profile
			if( user.userId == tmpUserId )
			{
				bioButton.imageEdgeInsets = UIEdgeInsetsMake( 4, 170, 0, 0 );
				[bioButton setImage:[UIImage imageNamed:@"disclosure_indicator.png"] forState:UIControlStateNormal];
				bioButton.enabled = YES;
			}
			else
			{
				bioButton = NO;
			}
			
			UILabel *bioLabel = [[UILabel alloc] initWithFrame:CGRectMake( 10, 10, 165, 30 )];
			bioLabel.text = user.bio;
			bioLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			bioLabel.font = [UIFont systemFontOfSize:13];
			bioLabel.backgroundColor = [UIColor clearColor];
			bioLabel.numberOfLines = 2;
			[bioButton addSubview:bioLabel];
			
			[cell addSubview:bioButton];
			[bioButton release];
			
			UIButton *dishButton = [[UIButton alloc] initWithFrame:CGRectMake( 103, 57, 104, 47 )];
			[dishButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_left.png"] forState:UIControlStateNormal];
			[dishButton addTarget:self action:@selector(dishButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:dishButton];
			[dishButton release];
			
			UILabel *dishCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 4, 94, 20 )];
			dishCountLabel.text = [NSString stringWithFormat:@"%d", user.dishCount];
			dishCountLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1];
			dishCountLabel.textAlignment = NSTextAlignmentCenter;
			dishCountLabel.font = [UIFont boldSystemFontOfSize:20];
			dishCountLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:dishCountLabel];
			
			UILabel *dishLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 20, 94, 20 )];
			dishLabel.text = @"Dishes";
			dishLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			dishLabel.textAlignment = NSTextAlignmentCenter;
			dishLabel.font = [UIFont systemFontOfSize:13];
			dishLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:dishLabel];
			
			UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake( 207, 57, 107, 47 )];
			[likeButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_right.png"] forState:UIControlStateNormal];
			[likeButton addTarget:self action:@selector(likeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:likeButton];
			[likeButton release];
			
			UILabel *likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 4, 97, 20 )];
			likeCountLabel.text = [NSString stringWithFormat:@"%d", user.yumCount];
			likeCountLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1];
			likeCountLabel.textAlignment = NSTextAlignmentCenter;
			likeCountLabel.font = [UIFont boldSystemFontOfSize:20];
			likeCountLabel.backgroundColor = [UIColor clearColor];
			[likeButton addSubview:likeCountLabel];
			
			UILabel *likeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 20, 97, 20 )];
			likeLabel.text = @"Likes";
			likeLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			likeLabel.textAlignment = NSTextAlignmentCenter;
			likeLabel.font = [UIFont systemFontOfSize:13];
			likeLabel.backgroundColor = [UIColor clearColor];
			[likeButton addSubview:likeLabel];
			
			arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
			arrowView.frame = CGRectMake( ARROW_LEFT_X, 101, 25, 11 );
			[cell addSubview:arrowView];
		}
		
		return cell;
	}
	
	else if( indexPath.section == 1 )
	{
		UITableViewCell *cell;
		
		// Dishes
		if( selectedTab == 0 )
		{
			cell = [_tableView dequeueReusableCellWithIdentifier:dishCellId];
			if( cell == nil )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dishCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				for( NSInteger i = 0; i < 3; i++ )
				{
					if( dishes.count > indexPath.row * 3 + i )
					{
						Dish *dish = [dishes objectAtIndex:indexPath.row * 3 + i];
						DishTileItem *dishItem = [[DishTileItem alloc] initWithDish:dish];
						dishItem.frame = CGRectMake( DISH_TILE_GAP * ( i + 1 ) + DISH_TILE_LEN * i, DISH_TILE_GAP, DISH_TILE_LEN, DISH_TILE_LEN );
						[dishItem addTarget:self action:@selector(dishItemDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
						[dishItem loadPhoto];
						[cell addSubview:dishItem];
						[dishItem release];
					}
				}
			}
		}
		
		// Likes
		else
		{
			cell = [_tableView dequeueReusableCellWithIdentifier:likeCellId];
			if( cell == nil )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:likeCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				for( NSInteger i = 0; i < 3; i++ )
				{
					if( likes.count > indexPath.row * 3 + i )
					{
						Dish *dish = [likes objectAtIndex:indexPath.row * 3 + i];
						DishTileItem *dishItem = [[DishTileItem alloc] initWithDish:dish];
						dishItem.frame = CGRectMake( DISH_TILE_GAP * ( i + 1 ) + DISH_TILE_LEN * i, DISH_TILE_GAP, DISH_TILE_LEN, DISH_TILE_LEN );
						[dishItem addTarget:self action:@selector(dishItemDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
						[dishItem loadPhoto];
						[cell addSubview:dishItem];
						[dishItem release];
					}
				}
			}
		}
		
		return cell;
	}
	
	return nil;
}


#pragma mark -
#pragma mark Selectors

- (void)dishButtonDidTouchUpInside
{
	selectedTab = 0;
	[tableView reloadData];
	
	CGRect frame = arrowView.frame;
	frame.origin.x = ARROW_LEFT_X;
	arrowView.frame = frame;
}

- (void)likeButtonDidTouchUpInside
{
	selectedTab = 1;
	[tableView reloadData];
	
	CGRect frame = arrowView.frame;
	frame.origin.x = ARROW_RIGHT_X;
	arrowView.frame = frame;
}

@end
