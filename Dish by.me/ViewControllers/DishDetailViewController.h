//
//  DishDetailViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APILoader.h"

@class Dish;

@interface DishDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, APILoaderDelegate>
{
	UITableView *tableView;
	Dish *dish;
	APILoader *loader;
	NSMutableArray *comments;
}

- (id)initWithDish:(Dish *)dish;

@end
