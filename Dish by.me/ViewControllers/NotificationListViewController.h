//
//  NotificationListViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface NotificationListViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
	UITableView *_tableView;
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _updating;
	BOOL _loading;
}

- (void)updateNotifications;

@end
