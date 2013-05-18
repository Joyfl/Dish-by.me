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
#import "DMPhotoViewerViewController.h"

@implementation RecipeViewerViewController

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	_recipe = recipe ? recipe : [[Recipe alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 8, 0, 304, DMRecipeHeight )];
	_scrollView.center = CGPointMake( _scrollView.center.x, UIScreenHeight / 2 - 20 );
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_infoViewerView = [[RecipeInfoViewerView alloc] initWithRecipe:_recipe];
	_infoViewerView.frame = CGRectMake( -2, 0, 304, DMRecipeHeight );
	[_infoViewerView setCurrentPage:0 numberOfPages:_recipe.contents.count + 1];
	
	// 그냥 addTarget:action: 하면 EXC_BAD_ACCESS 에러남 ㅡㅡ;;
	[_infoViewerView.checkButton addTargetBlock:^(id sender) { [self dismiss]; } forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_infoViewerView];
	
	_contentViewerViews = [NSMutableArray array];
	for( NSInteger i = 0; i < _recipe.contents.count ; i++ )
	{
		RecipeContentViewerView *contentViewerView = [[RecipeContentViewerView alloc] initWithRecipeContent:[_recipe.contents objectAtIndex:i]];
		contentViewerView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 304, DMRecipeHeight );
		
		// 그냥 addTarget:action: 하면 EXC_BAD_ACCESS 에러남 ㅡㅡ;;
		[contentViewerView.checkButton addTargetBlock:^(id sender) { [self dismiss]; } forControlEvents:UIControlEventTouchUpInside];
		[contentViewerView.photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[contentViewerView setCurrentPage:i + 1 numberOfPages:_recipe.contents.count + 1];
		[_scrollView addSubview:contentViewerView];
		[_contentViewerViews addObject:contentViewerView];
	}
	
	_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), DMRecipeHeight );
	
	return self;
}

- (void)presentAnimation
{
	_scrollView.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	
	[UIView animateWithDuration:0.4 animations:^{
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		_scrollView.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 - 20 );
	}];
}

- (void)dismiss
{
	[self.view endEditing:YES];
	[self.delegate recipeViewerViewControllerWillDismiss:self];
	[UIView animateWithDuration:0.4 animations:^{
		_scrollView.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	} completion:^(BOOL finished) {
		[self dismissViewControllerAnimated:NO completion:nil];
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	}];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.delegate recipeViewerViewControllerDidDismiss:self];
	});
}

- (void)animateRecipes
{
	
}

- (void)photoButtonDidTouchUpInside:(UIButton *)photoButton
{
	RecipeContent *content = [(RecipeContentViewerView *)photoButton.superview.superview content];
	DMPhotoViewerViewController *photoViewer = [[DMPhotoViewerViewController alloc] initWithPhotoURL:[NSURL URLWithString:content.photoURL] thumbnailImage:[photoButton backgroundImageForState:UIControlStateNormal]];
	photoViewer.originRect = [photoViewer.view convertRect:photoButton.frame fromView:photoButton.superview];
	self.modalPresentationStyle = UIModalPresentationCurrentContext;
	[self presentViewController:photoViewer animated:NO completion:nil];
}

@end