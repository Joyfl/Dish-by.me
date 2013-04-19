//
//  RecipeInfoEditorView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeInfoEditorView : UIView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
	UITableView *_tableView;
	UITextField *_servingsInput;
	UILabel *_servingsLabel;
	UITextField *_minutesInput;
	UILabel *_minutesLabel;
	UIView *_pageControlView;
}

@property (nonatomic) Recipe *recipe;
@property (nonatomic) UIButton *checkButton;

- (id)initWithRecipe:(Recipe *)recipe;
- (void)setCurrentPage:(NSInteger)currentPage numberOfPages:(NSInteger)numberOfPages;

@end
