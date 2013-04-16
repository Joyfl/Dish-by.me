//
//  FacebookSettingsViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 16..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "DMSwitchCell.h"

@interface FacebookSettingsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, DMSwitchCellDelegate>
{
	UITableView *_tableView;
	NSMutableDictionary *_settings;
}

- (id)initWithSettings:(NSMutableDictionary *)settings;

@end
