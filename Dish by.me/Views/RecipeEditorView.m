//
//  RecipeEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeEditorView.h"
#import "RecipeInfoEditorView.h"

@implementation RecipeEditorView

- (id)init
{
	self = [super initWithFrame:CGRectMake( 0, 0, UIScreenWidth, 451 )];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[self addSubview:_scrollView];
	
	RecipeInfoEditorView *info = [[RecipeInfoEditorView alloc] init];
	[_scrollView addSubview:info];
	
	return self;
}

@end
