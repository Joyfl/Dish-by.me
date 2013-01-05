//
//  SearchViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLHTTPLoader.h"

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, JLHTTPLoaderDelegate>
{
	UIView *_searchBar;
	UITextField *_searchInput;
	UITableView *_tableView;
	
	NSMutableArray *_dishes;
	JLHTTPLoader *_loader;
}

@end
