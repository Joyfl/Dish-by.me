//
//  UIView+UIView_Dim.m
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 25..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "UIViewController+Dim.h"
#import <objc/runtime.h>

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


#pragma mark -
#pragma mark Dim

- (void)dim
{
	[self dimAnimated:YES];
}

- (void)dimAnimated:(BOOL)animated
{
	[self dimWithDuration:animated ? 0.25 : 0 completion:nil];
}

- (void)dimWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
	[self dimWithDuration:duration delay:0 completion:completion];
}

- (void)dimWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion
{
	if( self.isDimmed ) return;
	[self setIsDimmed:YES];
	
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


#pragma mark -
#pragma mark Undim

- (void)undim
{
	[self undimWithDuration:0.25 completion:nil];
}

- (void)undimAnimated:(BOOL)animated
{
	[self undimWithDuration:animated ? 0.25 : 0 completion:nil];
}

- (void)undimWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
	[self undimWithDuration:duration delay:0 completion:completion];
}

- (void)undimWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion
{
	if( !self.isDimmed ) return;
	[self setIsDimmed:NO];
	
	UIImageView *dimView = [self dimView];
	
	[UIView animateWithDuration:duration delay:delay options:0 animations:^{
		dimView.alpha = 0;
		
	} completion:^(BOOL finished) {
		[[[UIApplication sharedApplication] keyWindow] addSubview:dimView];
		if( completion )
			completion( finished );
	}];
}


#pragma mark -
#pragma mark isDimmed

- (void)setIsDimmed:(BOOL)isDimmed
{
	objc_setAssociatedObject( self, "_isDimmed", [NSNumber numberWithBool:isDimmed], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

- (BOOL)isDimmed
{
	return [objc_getAssociatedObject( self, "_isDimmed" ) boolValue];
}

@end
