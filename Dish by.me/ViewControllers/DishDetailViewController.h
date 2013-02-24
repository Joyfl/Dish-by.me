//
//  DishDetailViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMButton.h"
#import "BookmarkButton.h"

@class Dish;

@interface DishDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, BookmarkButtonDelegate>
{
	Dish *_dish;
	NSMutableArray *_comments;
	NSInteger _commentOffset;
	BOOL _loadedAllComments;
	
	BOOL lastLoggedIn;
	
	UITableView *_tableView;
	UIImageView *_topView;
	UIImageView *_midView;
	UIImageView *_botView;
	
	CGFloat _contentRowHeight;
	
	UILabel *_timeLabel;
	UIButton *_recipeButton;
	UIImageView *_bookmarkIconView;
	UILabel *_bookmarkLabel;
	BookmarkButton *_bookmarkButton;
	UIButton *_moreCommentsButton;
	UIActivityIndicatorView *_moreCommentsIndicatorView;
	UIView *_commentBar;
	UITextField *_commentInput;
	DMButton *_sendButton;
}

- (id)initWithDish:(Dish *)dish;

@end
