//
//  RecipeViewerViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Recipe.h"
#import "RecipeInfoViewerView.h"
#import "RecipeContentViewerView.h"
#import "GAI.h"

@protocol RecipeViewerViewControllerDelegate;

@interface RecipeViewerViewController : GAITrackedViewController
{
	UIScrollView *_scrollView;
	RecipeInfoViewerView *_infoViewerView;
	NSMutableArray *_contentViewerViews;
}

@property (nonatomic, weak) id<RecipeViewerViewControllerDelegate> delegate;
@property (nonatomic) Recipe *recipe;

- (id)initWithRecipe:(Recipe *)recipe;
- (void)presentAfterDelay:(NSTimeInterval)delay;
- (void)dismiss;

@end


@protocol RecipeViewerViewControllerDelegate <NSObject>

@optional
- (void)recipeViewerViewControllerWillDismiss:(RecipeViewerViewController *)recipeViewerViewController;
- (void)recipeViewerViewControllerDidDismiss:(RecipeViewerViewController *)recipeViewerViewController;

@end