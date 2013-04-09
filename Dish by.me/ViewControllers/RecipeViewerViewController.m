//
//  RecipeViewerViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeViewerViewController.h"
#import "UIResponder+Dim.h"
#import <QuartzCore/QuartzCore.h>

@implementation RecipeViewerViewController

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	_recipe = recipe ? recipe : [[Recipe alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 8, 0, 304, 451 )];
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_infoViewerView = [[RecipeInfoViewerView alloc] initWithRecipe:_recipe];
	_infoViewerView.frame = CGRectMake( -2, 0, 304, 451 );
	
	// 그냥 addTarget:action: 하면 EXC_BAD_ACCESS 에러남 ㅡㅡ;;
	[_infoViewerView.checkButton addTargetBlock:^(id sender) { [self dismiss]; } forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_infoViewerView];
	
	_contentViewerViews = [NSMutableArray array];
	for( NSInteger i = 0; i < _recipe.contents.count ; i++ )
	{
		RecipeContentViewerView *contentViewerView = [[RecipeContentViewerView alloc] initWithRecipeContent:[_recipe.contents objectAtIndex:i]];
		contentViewerView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 304, 451 );
		
		// 그냥 addTarget:action: 하면 EXC_BAD_ACCESS 에러남 ㅡㅡ;;
		[contentViewerView.checkButton addTargetBlock:^(id sender) { [self dismiss]; } forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:contentViewerView];
		[_contentViewerViews addObject:contentViewerView];
	}
	
	_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), 451 );
	
	return self;
}

- (void)presentAfterDelay:(NSTimeInterval)delay
{
	NSTimeInterval duration = 0.4;
	
	[self dimWithDuration:duration completion:nil];
	
	self.view.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	
	[UIView animateWithDuration:duration delay:delay options:0 animations:^{
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
		
		self.view.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 + 10 );
		
	} completion:^(BOOL finished) {
		[self animateRecipes];
		[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
	}];
}

- (void)dismiss
{
	NSTimeInterval duration = 0.4;
	
	if( [self.delegate respondsToSelector:@selector(recipeViewerViewControllerWillDismiss:)] )
		[self.delegate recipeViewerViewControllerWillDismiss:self];
	
	[self.view endEditing:YES];
	[self undimWithDuration:duration completion:nil];
	
	[UIView animateWithDuration:duration animations:^{
		self.view.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
		
	} completion:^(BOOL finished) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
		[self.view removeFromSuperview];
	}];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.delegate recipeViewerViewControllerDidDismiss:self];
	});
}

- (void)animateRecipes
{
	
}

@end