//
//  SettingsViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "DMSwitchCell.h"
#import "Settings.h"

@interface SettingsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, DMSwitchCellDelegate>
{
	UITableView *_tableView;
	UIActivityIndicatorView *_loadingIndicatorView;
	Settings *_settings;
}

- (void)loadSettings;

@end
