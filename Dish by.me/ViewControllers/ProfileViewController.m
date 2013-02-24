//
//  MeViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "ProfileViewController.h"
#import "Utils.h"
#import "User.h"
#import "Dish.h"
#import "DishTileItem.h"
#import "DishTileCell.h"
#import "DishDetailViewController.h"
#import "UserManager.h"

#define ARROW_LEFT_X	142
#define ARROW_RIGHT_X	248

@implementation ProfileViewController

enum {
	krequestIdUser = 0,
	krequestIdDishes = 1,
	krequestIdLikes = 2
};

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	_dishes = [[NSMutableArray alloc] init];
	_likes = [[NSMutableArray alloc] init];
	
	_loader = [[JLHTTPLoader alloc] init];
	_loader.delegate = self;
	
	self.navigationItem.title = @"Dish by.me";
	
	return self;
}

- (void)activateWithUserId:(NSInteger)userId
{
	NSString *rootUrl = API_ROOT_URL;
//	[_loader addrequestWithrequestId:krequestIdUser url:[NSString stringWithFormat:@"%@/user/%d", rootUrl, userId] method:JLHTTPLoaderMethodGET params:nil];
//	[_loader addrequestWithrequestId:krequestIdDishes url:[NSString stringWithFormat:@"%@/user/%d/dish", rootUrl, userId] method:JLHTTPLoaderMethodGET params:nil];
//	[_loader addrequestWithrequestId:krequestIdLikes url:[NSString stringWithFormat:@"%@/user/%d/yum", rootUrl, userId] method:JLHTTPLoaderMethodGET params:nil];
	[_loader startLoading];
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
#pragma mark JLHTTPLoaderDelegate

- (void)loaderDidFinishLoading:(JLHTTPResponse *)response
{
	NSDictionary *result = [Utils parseJSON:response.body];
	
	if( response.requestId == krequestIdUser )
	{
		_user = [[User alloc] init];
		_user.userId = [[result objectForKey:@"user_id"] integerValue];
		_user.name = [result objectForKey:@"user_name"];
		_user.bio =[result objectForKey:@"bio"];
		_user.dishCount = [[result objectForKey:@"dish_count"] integerValue];
		_user.bookmarkCount = [[result objectForKey:@"yum_count"] integerValue];
		
		self.navigationItem.title = _user.name;
		
		dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
			NSString *rootURL = WEB_ROOT_URL;
			NSString *url = [NSString stringWithFormat:@"%@/images/original/profile/%d.jpg", rootURL, _user.userId];
			NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
			if( data == nil )
				return;
			
			dispatch_async( dispatch_get_main_queue(), ^{
				_user.photo = [UIImage imageWithData:data];
			} );
		});
	}
	
	else if( response.requestId == krequestIdDishes )
	{
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 367 )];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
		[self.view addSubview:_tableView];
	}
	
	else if( response.requestId == krequestIdLikes )
	{
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_likes addObject:dish];
		}
		
		[_tableView reloadData];
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
	
	return _selectedTab == 0 ? ceil( _dishes.count / 3.0 ) : ceil( _likes.count / 3.0 );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 )
		return 105;
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *profileCellId = @"profileCell";
	static NSString *dishCellId = @"dishCell";
	static NSString *likeCellId = @"likeCell";
	
	if( indexPath.section == 0 )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileCellId];
		if( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			_profileImage = [[UIButton alloc] initWithFrame:CGRectMake( 14, 14, 85, 86 )];
			[_profileImage setBackgroundImage:_user.photo forState:UIControlStateNormal];
			[cell addSubview:_profileImage];
			
			UIImageView *profileBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_border.png"]];
			profileBorder.frame = CGRectMake( 10, 10, 93, 94 );
			[cell addSubview:profileBorder];
			
			UIButton *bioButton = [[UIButton alloc] initWithFrame:CGRectMake( 103, 10, 211, 47 )];
			bioButton.titleLabel.font = [UIFont systemFontOfSize:13];
			bioButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			[bioButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_top.png"] forState:UIControlStateNormal];
			
			// My profile
			if( _user.userId == [[UserManager manager] userId] )
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
			bioLabel.text = _user.bio;
			bioLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			bioLabel.font = [UIFont systemFontOfSize:13];
			bioLabel.backgroundColor = [UIColor clearColor];
			bioLabel.numberOfLines = 2;
			[bioButton addSubview:bioLabel];
			
			[cell addSubview:bioButton];
			
			UIButton *dishButton = [[UIButton alloc] initWithFrame:CGRectMake( 103, 57, 104, 47 )];
			[dishButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_left.png"] forState:UIControlStateNormal];
			[dishButton addTarget:self action:@selector(dishButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:dishButton];
			
			UILabel *dishCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 4, 94, 20 )];
			dishCountLabel.text = [NSString stringWithFormat:@"%d", _user.dishCount];
			dishCountLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1];
			dishCountLabel.textAlignment = NSTextAlignmentCenter;
			dishCountLabel.font = [UIFont boldSystemFontOfSize:20];
			dishCountLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:dishCountLabel];
			
			UILabel *dishLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 20, 94, 20 )];
			dishLabel.text = NSLocalizedString( @"DISHES", @"" );
			dishLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			dishLabel.textAlignment = NSTextAlignmentCenter;
			dishLabel.font = [UIFont systemFontOfSize:13];
			dishLabel.backgroundColor = [UIColor clearColor];
			[dishButton addSubview:dishLabel];
			
			UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake( 207, 57, 107, 47 )];
			[likeButton setBackgroundImage:[UIImage imageNamed:@"profile_cell_bottom_right.png"] forState:UIControlStateNormal];
			[likeButton addTarget:self action:@selector(likeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:likeButton];
			
			UILabel *likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 4, 97, 20 )];
			likeCountLabel.text = [NSString stringWithFormat:@"%d", _user.bookmarkCount];
			likeCountLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1];
			likeCountLabel.textAlignment = NSTextAlignmentCenter;
			likeCountLabel.font = [UIFont boldSystemFontOfSize:20];
			likeCountLabel.backgroundColor = [UIColor clearColor];
			[likeButton addSubview:likeCountLabel];
			
			UILabel *likeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5, 20, 97, 20 )];
			likeLabel.text = NSLocalizedString( @"LIKES", @"" );
			likeLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1];
			likeLabel.textAlignment = NSTextAlignmentCenter;
			likeLabel.font = [UIFont systemFontOfSize:13];
			likeLabel.backgroundColor = [UIColor clearColor];
			[likeButton addSubview:likeLabel];
			
			_arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
			_arrowView.frame = CGRectMake( ARROW_LEFT_X, 101, 25, 11 );
			[cell addSubview:_arrowView];
		}
		
		return cell;
	}
	
	else if( indexPath.section == 1 )
	{
		DishTileCell *cell;
		
		// Dishes
		if( _selectedTab == 0 )
		{
			cell = [tableView dequeueReusableCellWithIdentifier:dishCellId];
			
			if( !cell )
			{
				cell = [[DishTileCell alloc] initWithReuseIdentifier:dishCellId target:self action:@selector(dishItemDidTouchUpInside:)];
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
		}
		
		// Likes
		else
		{
			cell = [_tableView dequeueReusableCellWithIdentifier:likeCellId];
			
			if( !cell )
			{
				cell = [[DishTileCell alloc] initWithReuseIdentifier:dishCellId target:self action:@selector(dishItemDidTouchUpInside:)];
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
		}
		
		return cell;
	}
	
	return nil;
}


#pragma mark -
#pragma mark Selectors

- (void)dishButtonDidTouchUpInside
{
	_selectedTab = 0;
	[_tableView reloadData];
	
	CGRect frame = _arrowView.frame;
	frame.origin.x = ARROW_LEFT_X;
	_arrowView.frame = frame;
}

- (void)likeButtonDidTouchUpInside
{
	_selectedTab = 1;
	[_tableView reloadData];
	
	CGRect frame = _arrowView.frame;
	frame.origin.x = ARROW_RIGHT_X;
	_arrowView.frame = frame;
}

- (void)dishItemDidTouchUpInside:(DishTileItem *)dishTileItem
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:dishTileItem.dish];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

@end
