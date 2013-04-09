//
//  RecipeContentViewerView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "RecipeContent.h"

@interface RecipeContentViewerView : UIView <UIImagePickerControllerDelegate, UITextViewDelegate>
{
	UIImageView *_bgView;
	UIScrollView *_scrollView;
	UIImageView *_borderView;
	UIImageView *_lineView;
	UIPlaceHolderTextView *_contentInput;
}

@property (nonatomic) RecipeContent *content;
@property (nonatomic) UIButton *checkButton;
@property (nonatomic) UIButton *photoButton;

- (id)initWithRecipeContent:(RecipeContent *)content;

@end
