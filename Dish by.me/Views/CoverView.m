//
//  CoverView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 28..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "CoverView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CoverView

- (id)init
{
	self = [super initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	self.image = [UIImage imageNamed:UIScreenHeight == 480 ? @"Default.png" : @"Default-568h.png"];
	self.layer.anchorPoint = CGPointMake( 0, 0.5 );
	self.center = CGPointMake( 0, 20 + self.frame.size.height / 2 );
	return self;
}

- (void)addToWindow
{
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
	[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self];
}

- (void)open
{
	[self openAfterDelay:0];
}

- (void)openAfterDelay:(NSTimeInterval)delay
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	[self addToWindow];
	
	self.transform = CGAffineTransformMakeTranslation( 0, 0 );
	CATransform3D transform = CATransform3DIdentity;
	
	transform = CATransform3DMakeRotation( M_PI_2, 0, -1, 0 );
	transform.m34 = 0.001f;
	transform.m14 = -0.0015f;
	
	[UIView animateWithDuration:1 delay:delay options:0 animations:^{
		self.layer.transform = transform;
		
	} completion:^(BOOL finished) {
		[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
		[self removeFromSuperview];
	}];
}

- (void)closeCompletion:(void (^)(CoverView *coverView))completion
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	[self addToWindow];
	
	CATransform3D transform = CATransform3DIdentity;
	transform = CATransform3DMakeRotation( M_PI_2, 0, -1, 0 );
	transform.m34 = 0.001f;
	transform.m14 = -0.0015f;
	self.layer.transform = transform;
	
	transform = CATransform3DMakeRotation( M_PI_2, 0, 0, 0 );
	
	[UIView animateWithDuration:1 animations:^{
		self.layer.transform = transform;
		
	} completion:^(BOOL finished) {
		[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
		if( completion ) completion( self );
	}];
}

@end
