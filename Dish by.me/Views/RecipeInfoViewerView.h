//
//  RecipeInfoViewerView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeInfoViewerView : UIView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
	UITableView *_tableView;
	UILabel *_servingsLabel;
	UILabel *_minutesLabel;
	UIView *_pageControlView;
}

@property (nonatomic) Recipe *recipe;
@property (nonatomic, readonly) UIButton *checkButton;

- (id)initWithRecipe:(Recipe *)recipe;
- (void)setCurrentPage:(NSInteger)currentPage numberOfPages:(NSInteger)numberOfPages;

@end
