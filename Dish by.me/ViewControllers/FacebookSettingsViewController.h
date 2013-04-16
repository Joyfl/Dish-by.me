//
//  FacebookSettingsViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 16..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "DMSwitchCell.h"
#import "Settings.h"

@interface FacebookSettingsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, DMSwitchCellDelegate>
{
	UITableView *_tableView;
	Settings *_settings;
}

- (id)initWithSettings:(Settings *)settings;

@end
