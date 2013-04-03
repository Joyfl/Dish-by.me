//
//  RecipeEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeEditorView.h"
#import "RecipeInfoEditorView.h"
#import "RecipeContentEditorView.h"
#import "UIResponder+Dim.h"

@implementation RecipeEditorView

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super initWithFrame:CGRectMake( 0, 0, UIScreenWidth, 451 )];
	
	_recipe = recipe ? recipe : [[Recipe alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 8, 0, 304, 451 )];
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self addSubview:_scrollView];
	
	_infoEditorView = [[RecipeInfoEditorView alloc] initWithRecipe:_recipe];
	_infoEditorView.frame = CGRectMake( -2, 0, 304, 451 );
	[_infoEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_infoEditorView];
	
	_contentEditorViews = [NSMutableArray array];
	for( NSInteger i = 0; i < _recipe.contents.count; i++ )
	{
		RecipeContentEditorView *contentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:[_recipe.contents objectAtIndex:i]];
		contentEditorView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 308, 451 );
		[contentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:contentEditorView];
		[_contentEditorViews addObject:contentEditorView];
	}
	
	_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), 451 );
	
	return self;
}

- (void)presentAfterDelay:(NSTimeInterval)delay
{
	NSTimeInterval duration = 0.4;
	
	[self dimWithDuration:duration completion:nil];
	
	self.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	
	[UIView animateWithDuration:duration delay:delay options:0 animations:^{
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		[[[UIApplication sharedApplication] keyWindow] addSubview:self];
		
		self.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 );
		
	} completion:^(BOOL finished) {
		[self animateRecipes];
	}];
}

- (void)dismiss
{
	NSTimeInterval duration = 0.4;
	
	if( [self.delegate respondsToSelector:@selector(recipeEditorViewWillDismiss:)] )
		[self.delegate recipeEditorViewWillDismiss:self];
	
	[self endEditing:YES];
	[self undimWithDuration:duration completion:nil];
	
	[UIView animateWithDuration:duration animations:^{
		self.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
		
	} completion:^(BOOL finished) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
		[self removeFromSuperview];
	}];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.delegate recipeEditorViewDidDismiss:self];
	});
}

- (void)animateRecipes
{
	
}

@end
