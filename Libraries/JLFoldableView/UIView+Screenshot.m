//
//  UIView+Screenshot.m
//  JLFoldableView
//
//  Created by 전수열 on 13. 2. 22..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//


#import "UIView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Screenshot)

- (UIImage *)screenshot
{
	if( UIGraphicsBeginImageContextWithOptions != NULL )
	{
		UIGraphicsBeginImageContextWithOptions( self.frame.size, NO, 0.0 );
	}
	else
	{
		UIGraphicsBeginImageContext( self.frame.size );
	}
	
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return screenshot;
}

@end
