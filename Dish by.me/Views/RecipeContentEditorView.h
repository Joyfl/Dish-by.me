//
//  RecipeContentEditorView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "RecipeContent.h"

@class RecipeEditorViewController;

@interface RecipeContentEditorView : UIView <UIImagePickerControllerDelegate, UITextViewDelegate>
{
	UIImageView *_bgView;
	UIScrollView *_scrollView;
	UIImageView *_borderView;
	UIImageView *_lineView;
	UIPlaceHolderTextView *_contentInput;
}

@property (nonatomic) RecipeContent *content;
@property (nonatomic, assign) CGPoint originalLocation;
@property (nonatomic) UIButton *grabButton;
@property (nonatomic) UIButton *checkButton;
@property (nonatomic) UIButton *photoButton;
@property (nonatomic, weak) RecipeEditorViewController *recipeEditorViewController;

- (id)initWithRecipeContent:(RecipeContent *)content;

@end
