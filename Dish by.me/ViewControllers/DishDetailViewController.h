//
//  DishDetailViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLHTTPLoader.h"

@class Dish;

@interface DishDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, JLHTTPLoaderDelegate>
{
	Dish *_dish;
	JLHTTPLoader *_loader;
	NSMutableArray *_comments;
	
	UITableView *_tableView;
	BOOL _scrollEnabled;
	
	CGFloat _messageRowHeight;
	UILabel *_forkedFromLabel;
	
	UIButton *_recipeButton;
	UIButton *_likeButton;
	UIView *_commentBar;
	UITextField *_commentInput;
	
	UIImageView *_dim;
}

- (id)initWithDish:(Dish *)dish;

@end
