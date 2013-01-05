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
	kRequestIdDishes = 0
};

- (id)init
{
    self = [super init];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 367 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xEE / 255.0 blue:0xEA / 255.0 alpha:1];
	[self.view addSubview:_tableView];
	
	_dishes = [[NSMutableArray alloc] init];
	
	_loader = [[JLHTTPLoader alloc] init];
	_loader.delegate = self;
	
	JLHTTPGETRequest *req = [[JLHTTPGETRequest alloc] init];
	req.url = [NSString stringWithFormat:@"%@dishes", API_ROOT_URL];
	[_loader addRequest:req];
	[_loader startLoading];
	
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
	[_tableView release];
	[_dishes release];
	[_loader release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark JLHTTPLoaderDelegate

- (void)loaderDidFinishLoading:(JLHTTPResponse *)response
{
	NSLog( @"%@", response.body );
	if( response.requestId == kRequestIdDishes )
	{
		if( response.statusCode == 200 )
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
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dishes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 350;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	
	DishListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if( !cell )
		cell = [[DishListCell alloc] initWithReuseIdentifier:cellId];
	
	cell.dish = [_dishes objectAtIndex:indexPath.row];
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
