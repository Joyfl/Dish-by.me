//
//  RecipeEditorView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import "RecipeInfoEditorView.h"
#import "RecipeContentEditorView.h"
#import "GAI.h"

@protocol RecipeEditorViewControllerDelegate;

@interface RecipeEditorViewController : GAITrackedViewController <UIScrollViewDelegate>
{
	UIScrollView *_scrollView;
	RecipeInfoEditorView *_infoEditorView;
	NSMutableArray *_contentEditorViews;
	RecipeContentEditorView *_newContentEditorView;
	RecipeContentEditorView *_currentDraggingContentEditorView;
	NSTimer *_pagingTimer;
}

@property (nonatomic, weak) id<RecipeEditorViewControllerDelegate> delegate;
@property (nonatomic, readonly) Recipe *recipe;

- (id)initWithRecipe:(Recipe *)recipe;
- (void)presentAfterDelay:(NSTimeInterval)delay;
- (void)dismiss;

@end


@protocol RecipeEditorViewControllerDelegate <NSObject>

@optional
- (void)recipeEditorViewControllerWillDismiss:(RecipeEditorViewController *)recipeEditorViewController;
- (void)recipeEditorViewControllerDidDismiss:(RecipeEditorViewController *)recipeEditorViewController;

@end