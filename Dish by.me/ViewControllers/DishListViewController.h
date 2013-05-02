//
//  DishViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "DishListCell.h"
#import "GAITrackedViewController.h"
#import "WritingViewController.h"

typedef enum {
	DMProgressStateIdle,
	DMProgressStateLoading,
	DMProgressStateFailure
} DMProgressState;

@interface DishListViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, DishListCellDelegate, WritingViewControllerDelegate>
{
	UITableView *_tableView;
	NSMutableArray *_dishes;
	NSInteger _offset;
	BOOL _loadedLastDish;
	
	BOOL _loading;
	BOOL _updating;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	// 업로드 관련 UI
	UIImageView *_progressView;
	UIImageView *_progressBar;
	UIImageView *_progressBarBackgroundView;
	UILabel *_progressFailedLabel;
	UIButton *_progressButton;
	UIButton *_cancelButton;
	DMProgressState _progressState;
	void (^_uploadBlock)(void);
	
	NSTimer *_scrollTimer; // 스크롤 후 일정시간이 지나면 DishListCell에서 프로필을 fade out시킨다.
}

- (void)updateDishes;

@end
