//
//  MeViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLHTTPLoader.h"

@class User;

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, JLHTTPLoaderDelegate>
{
	User *_user;
	
	UIButton *_profileImage;
	UIImageView *_arrowView;
	UITableView *_tableView;
	
	NSMutableArray *_dishes;
	NSMutableArray *_likes;
	
	// 0 : dishes
	// 1 : likes
	NSInteger _selectedTab;
	
	JLHTTPLoader *_loader;
}

- (void)activateWithUserId:(NSInteger)userId;

@end
