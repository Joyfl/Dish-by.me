//
//  FacebookSettingsViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 25..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface FacebookSettingsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>
{
	UITableView *_tableView;
}

@end
