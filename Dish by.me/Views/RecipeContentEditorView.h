//
//  RecipeContentEditorView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface RecipeContentEditorView : UIView <UITextViewDelegate>
{
	UIImageView *_bgView;
	UIScrollView *_scrollView;
	UIButton *_photoButton;
	UIImageView *_borderView;
	UIImageView *_lineView;
	UIPlaceHolderTextView *_contentInput;
}

@property (nonatomic) UIButton *checkButton;

@end
