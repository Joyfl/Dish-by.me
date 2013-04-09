//
//  RecipeViewerViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Recipe.h"
#import "RecipeInfoEditorView.h"
#import "RecipeContentEditorView.h"
#import "GAI.h"

@protocol RecipeViewerViewControllerDelegate;

@interface RecipeViewerViewController : GAITrackedViewController <UIScrollViewDelegate>
{
	UIScrollView *_scrollView;
	RecipeInfoEditorView *_infoEditorView;
	NSMutableArray *_contentEditorViews;
	RecipeContentEditorView *_newContentEditorView;
	RecipeContentEditorView *_currentDraggingContentEditorView;
	NSTimer *_pagingTimer;
}

@property (nonatomic, weak) id<RecipeViewerViewControllerDelegate> delegate;
@property (nonatomic, strong) UITextView *recipeView; // 없애기
@property (nonatomic) Recipe *recipe;

- (id)initWithRecipe:(Recipe *)recipe;
- (void)presentAfterDelay:(NSTimeInterval)delay;
- (void)dismiss;

@end


@protocol RecipeViewerViewControllerDelegate <NSObject>

@optional
- (void)recipeViewerViewWillDismiss:(RecipeViewerViewController *)recipeViewerViewController;
- (void)recipeViewerViewDidDismiss:(RecipeViewerViewController *)recipeViewerViewController;

@end