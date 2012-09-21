//
//  DishViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APILoader.h"

@interface DishViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, APILoaderDelegate>
{
	UITableView *tableView;
	NSMutableArray *dishes;
	APILoader *loader;
}

@end
