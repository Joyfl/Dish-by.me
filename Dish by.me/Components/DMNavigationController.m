//
//  DishByMeNavigationController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DMNavigationController.h"


@implementation DMNavigationController

- (id)initWithRootViewController:rootViewController
{
	self = [super initWithRootViewController:_rootViewController = rootViewController];
	
	[self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   [UIFont fontWithName:@"SegoeUI-Bold" size:18], UITextAttributeFont,
						   [UIColor colorWithWhite:0 alpha:0.2], UITextAttributeTextShadowColor,
						   [NSValue valueWithUIOffset:UIOffsetMake( 0, 1 )], UITextAttributeTextShadowOffset, nil];
	[self.navigationBar setTitleTextAttributes:attrs];
	[self.navigationBar setTitleVerticalPositionAdjustment:-2 forBarMetrics:UIBarMetricsDefault];
	
	return self;
}

@end
