//
//  JLLabelButton.m
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 27..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "JLLabelButton.h"
#import <QuartzCore/CALayer.h>

@implementation JLLabelButton

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	_highlightView = [[UIView alloc] init];
	_highlightView.backgroundColor = [UIColor lightGrayColor];
	_highlightView.layer.cornerRadius = 3;
	_highlightView.clipsToBounds = YES;
	_highlightView.hidden = YES;
	[self insertSubview:_highlightView belowSubview:self.imageView];
	
//	_hightlightViewInsets = UIEdgeInsetsMake( -2, -2, -2, -2 );
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	_highlightView.frame = UIEdgeInsetsInsetRect( rect, _hightlightViewInsets );
}

- (void)setHighlighted:(BOOL)highlighted
{
	_highlightView.hidden = !highlighted;
}

@end
