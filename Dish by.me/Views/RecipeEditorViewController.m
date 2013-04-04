//
//  RecipeEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeEditorViewController.h"
#import "UIResponder+Dim.h"
#import <QuartzCore/QuartzCore.h>

@implementation RecipeEditorViewController

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	_recipe = recipe ? recipe : [[Recipe alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 8, 0, 304, 451 )];
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_infoEditorView = [[RecipeInfoEditorView alloc] initWithRecipe:_recipe];
	_infoEditorView.frame = CGRectMake( -2, 0, 304, 451 );
	[_infoEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_infoEditorView];
	
	_contentEditorViews = [NSMutableArray array];
	for( NSInteger i = 0; i < _recipe.contents.count; i++ )
	{
		RecipeContentEditorView *contentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:[_recipe.contents objectAtIndex:i]];
		contentEditorView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 304, 451 );
		[contentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:contentEditorView];
		[_contentEditorViews addObject:contentEditorView];
	}
	
	_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), 451 );
	
	_newContentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:nil];
	_newContentEditorView.frame = CGRectOffset( _newContentEditorView.frame, UIScreenWidth, 0 );
	_newContentEditorView.layer.anchorPoint = CGPointMake( 0, 0.5 );
	[self.view addSubview:_newContentEditorView];
	
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
	
	if( [self.delegate respondsToSelector:@selector(recipeEditorViewWillDismiss:)] )
		[self.delegate recipeEditorViewWillDismiss:self];
	
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
		[self.delegate recipeEditorViewDidDismiss:self];
	});
}

- (void)animateRecipes
{
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat offset = scrollView.contentOffset.x;
	RecipeContentEditorView *lastView = [_contentEditorViews lastObject];
	
	// 추가되기 전 : _newContentEditorView
	if( scrollView.scrollEnabled )
	{
		CGRect lastViewFrame = [scrollView convertRect:lastView.frame toView:self.view];
		_newContentEditorView.frame = CGRectOffset( lastViewFrame, 304, 0 );
		
		if( offset >= _scrollView.contentSize.width - 304 )
		{
			CGFloat angle = M_PI * (offset - 304 * (_contentEditorViews.count + 1) ) / 608.0;
			CATransform3D transform = CATransform3DMakeRotation( angle, 0, 1, 0 );
			transform.m34 = -1 / 500.0;
			transform.m14 = -angle / 500;
			_newContentEditorView.layer.transform = transform;
		}
	}
	
	// 추가되는 중 : lastView
	else
	{
		CGFloat angle = M_PI * (offset - 304 * (_contentEditorViews.count) ) / 608.0;
		CATransform3D transform = CATransform3DMakeRotation( angle, 0, 1, 0 );
		transform.m34 = -1 / 500.0;
		transform.m14 = -angle / 500;
		lastView.layer.transform = transform;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	CGFloat offset = scrollView.contentOffset.x;
	if( offset >= _scrollView.contentSize.width - 304 + 60 )
	{
		JLLog( @"Added RecipeContentEditorView" );
		
		scrollView.scrollEnabled = NO;
		
		RecipeContent *newContent = [[RecipeContent alloc] init];
		[_recipe.contents addObject:newContent];
		
		RecipeContentEditorView *newContentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:newContent];
		[newContentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		newContentEditorView.layer.anchorPoint = CGPointMake( 0, 0.5 );
		newContentEditorView.layer.transform = _newContentEditorView.layer.transform;
		newContentEditorView.frame = CGRectMake( 304 * _recipe.contents.count, 0, 304, 451 );
		_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), 451 );
		[_scrollView addSubview:newContentEditorView];
		
		[_contentEditorViews addObject:newContentEditorView];
		
		_newContentEditorView.layer.transform = CATransform3DIdentity;
		_newContentEditorView.frame = CGRectMake( UIScreenWidth, 0, 304, 451 );
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if( !scrollView.scrollEnabled )
	{
		scrollView.scrollEnabled = NO;
		
		RecipeContentEditorView *lastAddedContentEditorView = [_contentEditorViews lastObject];
		[scrollView setContentOffset:lastAddedContentEditorView.frame.origin animated:YES];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if( !scrollView.scrollEnabled )
	{
		scrollView.scrollEnabled = YES;
	}
}

@end
