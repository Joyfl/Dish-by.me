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

@protocol RecipeEditorViewDelegate;

@interface RecipeEditorView : UIView
{
	UIScrollView *_scrollView;
	RecipeInfoEditorView *_infoEditorView;
	NSMutableArray *_contentEditorViews;
}

@property (nonatomic, weak) id<RecipeEditorViewDelegate> delegate;
@property (nonatomic, strong) UITextView *recipeView; // 없애기
@property (nonatomic) Recipe *recipe;

- (id)initWithRecipe:(Recipe *)recipe;
- (void)presentAfterDelay:(NSTimeInterval)delay;
- (void)dismiss;

@end


@protocol RecipeEditorViewDelegate <NSObject>

@optional
- (void)recipeEditorViewWillDismiss:(RecipeEditorView *)recipeEditorView;
- (void)recipeEditorViewDidDismiss:(RecipeEditorView *)recipeEditorView;

@end