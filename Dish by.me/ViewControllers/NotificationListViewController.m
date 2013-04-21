//
//  NotificationListViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "NotificationListViewController.h"
#import "AppDelegate.h"
#import "NotificationCell.h"
#import "DMBarButtonItem.h"
#import "ProfileViewController.h"

#define notifications [(AppDelegate *)[UIApplication sharedApplication].delegate notifications]
#define isLastNotificationLoaded [(AppDelegate *)[UIApplication sharedApplication].delegate isLastNotificationLoaded]

@implementation NotificationListViewController

- (id)init
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [self.class description];
	
	[DMBarButtonItem setBackButtonToViewController:self];
	self.navigationItem.title = NSLocalizedString( @"NOTIFICATIONS", nil );
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, -2, 320, UIScreenHeight - 112 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = self.view.backgroundColor;
	_tableView.scrollIndicatorInsets = UIEdgeInsetsMake( 2, 0, 0, 0 );
	[self.view addSubview:_tableView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake( 0, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height )];
	_refreshHeaderView.delegate = self;
	_refreshHeaderView.dottedLineView.hidden = YES;
	_refreshHeaderView.backgroundColor = self.view.backgroundColor;
	[_tableView addSubview:_refreshHeaderView];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[_tableView reloadData];
}

- (void)updateNotifications
{
	_updating = YES;
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate updateNotificationsSuccess:^{
		[_tableView reloadData];
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
		[(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController].notificationsCount = 0;
		[[DMAPILoader sharedLoader] api:@"/notifications" method:@"PUT" parameters:nil success:nil failure:nil];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)loadMoreNotifications
{
	_loading = YES;
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate loadMoreNotificationsSuccess:^{
		[_tableView reloadData];
		_loading = NO;
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		_loading = NO;
	}];
}

- (void)readNotification:(Notification *)notification
{
	NSString *api = [NSString stringWithFormat:@"/notification/%d", notification.notificationId];
	[[DMAPILoader sharedLoader] api:api method:@"PUT" parameters:@{@"checked": @YES} success:^(id response) {
		
		notification.read = YES;
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
	}];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1 + !isLastNotificationLoaded;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 1 ) return 1;
	return notifications.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 1 ) return 45;
	return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"notificationCellId";
	
	if( indexPath.section == 0 )
	{
		NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if( !cell )
		{
			cell = [[NotificationCell alloc] initWithReuseIdentifier:cellId];
		}
		
		Notification *notification = [notifications objectAtIndex:indexPath.row];
		[cell setNotification:notification atIndexPath:indexPath];
		
		cell.bottomLineView.hidden = indexPath.row != notifications.count - 1;
		
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
		
		if( !_loading )
			[self loadMoreNotifications];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Notification *notification = [notifications objectAtIndex:indexPath.row];
	[self readNotification:notification];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:notification.url]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)refreshHeaerView
{
	[self updateNotifications];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)refreshHeaerView
{
	return _updating;
}

@end
