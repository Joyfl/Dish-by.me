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

@interface RecipeContentEditorView : UIView <UIImagePickerControllerDelegate, UITextViewDelegate>
{
	UIImageView *_bgView;
	UIScrollView *_scrollView;
	UIImageView *_borderView;
	UIImageView *_lineView;
	UIPlaceHolderTextView *_textView;
}

@property (nonatomic) RecipeContent *content;
@property (nonatomic, assign) CGPoint originalLocation;
@property (nonatomic, readonly) UIButton *grabButton;
@property (nonatomic, readonly) UIButton *checkButton;
@property (nonatomic, readonly) UIButton *photoButton;
@property (nonatomic, readonly) UITextView *textView;

- (id)initWithRecipeContent:(RecipeContent *)content;
- (void)setPhotoButtonImage:(UIImage *)image;

@end
