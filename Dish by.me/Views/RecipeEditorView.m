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

- (id)init
{
	self = [super initWithFrame:CGRectMake( 0, 0, UIScreenWidth, 451 )];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_scrollView.pagingEnabled = YES;
	[self addSubview:_scrollView];
	
	RecipeInfoEditorView *info = [[RecipeInfoEditorView alloc] init];
	info.frame = CGRectMake( 6, 0, 308, 451 );
	[info.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:info];
	
	RecipeContentEditorView *content = [[RecipeContentEditorView alloc] init];
	content.frame = CGRectMake( 326, 0, 308, 451 );
	[content.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:content];
	
	_scrollView.contentSize = CGSizeMake( 640, 451 );
	
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
	} completion:nil];
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

@end
