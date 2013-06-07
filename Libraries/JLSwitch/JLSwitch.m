//
//  JLSwitch.m
//  JLSwitch
//
//  Created by 전수열 on 13. 6. 7..
//  Copyright (c) 2013년 전수열. All rights reserved.
//

#import "JLSwitch.h"
#import "UIButton+TouchAreaInsets.h"

@implementation JLSwitch

- (id)init
{
	return [self initWithFrame:CGRectMake( 0, 0, 77, 28 )];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:CGRectMake( frame.origin.x, frame.origin.y, 77, 28 )];
	self.clipsToBounds = YES;
	
	_backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
	_backgroundView.image = [UIImage imageNamed:@"switch_background.png"];
	[self addSubview:_backgroundView];
	
	_blueBackgroundView = [[UIImageView alloc] init];
	_blueBackgroundView.image = [[UIImage imageNamed:@"switch_background_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 10, 10, 10, 10 )];
	[self addSubview:_blueBackgroundView];
	
	_onIcon = [[UIImageView alloc] init];
	_onIcon.image = [UIImage imageNamed:@"switch_icon_on.png"];
	[_blueBackgroundView addSubview:_onIcon];
	
	_offIcon = [[UIImageView alloc] init];
	_offIcon.image = [UIImage imageNamed:@"switch_icon_off.png"];
	[self addSubview:_offIcon];
	
	_knob = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 27, 27 )];
	_knob.touchAreaInsets = UIEdgeInsetsMake( 27, 27, 27, 27 );
	_knob.adjustsImageWhenHighlighted = NO;
	[_knob setBackgroundImage:[UIImage imageNamed:@"switch_knob.png"] forState:UIControlStateNormal];
	[_knob setBackgroundImage:[UIImage imageNamed:@"switch_knob_selected.png"] forState:UIControlStateHighlighted];
	[_knob addTarget:self action:@selector(knobDidTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
	[_knob addTarget:self action:@selector(knobDidDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	[_knob addTarget:self action:@selector(knobDidDrag:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
	[_knob addTarget:self action:@selector(knobDidTouchUp) forControlEvents:UIControlEventTouchUpInside];
	[_knob addTarget:self action:@selector(knobDidTouchUp) forControlEvents:UIControlEventTouchUpOutside];
	[self addSubview:_knob];
	
	_knobBlueBorder = [[UIImageView alloc] initWithFrame:_knob.bounds];
	_knobBlueBorder.image = [UIImage imageNamed:@"switch_knob_border_blue.png"];
	_knobBlueBorder.userInteractionEnabled = NO;
	[_knob addSubview:_knobBlueBorder];
	
	[self layoutComponents];
	
	return self;
}

- (void)knobDidTouchDown:(UIButton *)button withEvent:(UIEvent *)event
{
	UITouch *touch = [[event touchesForView:button] anyObject];
	CGPoint location = [touch locationInView:self];
	_touchDistance = button.frame.origin.x - location.x;
}

- (void)knobDidDrag:(UIButton *)button withEvent:(UIEvent *)event
{
	_dragging = YES;
	
	UITouch *touch = [[event touchesForView:button] anyObject];
	CGPoint location = [touch locationInView:self];
	
	CGFloat buttonX = location.x + _touchDistance;
	if( buttonX < 0 ) buttonX = 0;
	else if( buttonX > 50 ) buttonX = 50;
	
	CGRect frame = button.frame;
	frame.origin.x = buttonX;
	button.frame = frame;
	
	[self layoutComponents];
}

- (void)knobDidTouchUp
{
	if( !_dragging )
	{
		self.on = !self.on;
	}
	else
	{
		self.on = _knob.frame.origin.x > 25;
	}
	
	_dragging = NO;
}

- (void)layoutComponents
{
	CGFloat buttonX = _knob.frame.origin.x;
	
	_blueBackgroundView.frame = CGRectMake( 0, 0, buttonX + 27, 28 );
	_blueBackgroundView.alpha = _knobBlueBorder.alpha = buttonX / 50.0;
	
	_onIcon.frame = CGRectMake( buttonX - 24, 7, 3, 14 );
	_offIcon.frame = CGRectMake( buttonX + 43, 7, 13, 14 );
}

- (void)setOn:(BOOL)on
{
	BOOL lastValue = self.on;
	[self setOn:on animated:YES];
	
	if( lastValue != on )
	{
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
	_on = on;
	
	NSTimeInterval duration = animated ? 0.25 : 0;
	
	if( on )
	{
		[UIView animateWithDuration:duration animations:^{
			CGRect frame = _knob.frame;
			frame.origin.x = 50;
			_knob.frame = frame;
			[self layoutComponents];
		}];
	}
	else
	{
		[UIView animateWithDuration:duration animations:^{
			CGRect frame = _knob.frame;
			frame.origin.x = 0;
			_knob.frame = frame;
			[self layoutComponents];
		}];
	}
}

@end
