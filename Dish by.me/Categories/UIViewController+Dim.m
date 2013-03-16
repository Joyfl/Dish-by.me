//
//  UIView+UIView_Dim.m
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 25..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "UIViewController+Dim.h"

@implementation UIViewController (Dim)

- (UIImageView *)dimView
{
	static UIImageView *dimView = nil;
	if( !dimView )
	{
		dimView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, UIScreenWidth, UIScreenHeight )];
		dimView.image = [UIImage imageNamed:@"dim.png"];
		dimView.userInteractionEnabled = YES;
	}
	return dimView;
}


- (void)dim
{
	[self dimWithDuration:0.25 completion:nil];
}

- (void)dimWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
	[self dimWithDuration:duration delay:0 completion:completion];
}

- (void)dimWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion
{
	UIImageView *dimView = [self dimView];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:dimView];
	dimView.alpha = 0;
	
	[UIView animateWithDuration:duration delay:delay options:0 animations:^{
		dimView.alpha = 1;
		
	} completion:^(BOOL finished) {
		if( completion )
			completion( finished );
	}];
}


- (void)undim
{
	[self undimWithDuration:0.25 completion:nil];
}

- (void)undimWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
	[self undimWithDuration:duration delay:0 completion:completion];
}

- (void)undimWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion
{
	UIImageView *dimView = [self dimView];
	
	[UIView animateWithDuration:duration delay:delay options:0 animations:^{
		dimView.alpha = 0;
		
	} completion:^(BOOL finished) {
		[[[UIApplication sharedApplication] keyWindow] addSubview:dimView];
		if( completion )
			completion( finished );
	}];
}

@end
