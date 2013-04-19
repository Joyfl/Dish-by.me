//
//  RecipeContentViewerView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeContent.h"

@interface RecipeContentViewerView : UIView
{
	UIImageView *_bgView;
	UIScrollView *_scrollView;
	UIImageView *_borderView;
	UIImageView *_lineView;
	UITextView *_textView;
	UIView *_pageControlView;
}

@property (nonatomic) RecipeContent *content;
@property (nonatomic, readonly) UIButton *checkButton;
@property (nonatomic, readonly) UIButton *photoButton;

- (id)initWithRecipeContent:(RecipeContent *)content;
- (void)setCurrentPage:(NSInteger)currentPage numberOfPages:(NSInteger)numberOfPages;

@end
