//
//  UIButton+TouchAreaInsets.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 22..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "UIButton+TouchAreaInsets.h"
#import <objc/runtime.h>

@implementation UIButton (TouchAreaInsets)

- (UIEdgeInsets)touchAreaInsets
{
	return [objc_getAssociatedObject( self, "_touchAreaInsets" ) UIEdgeInsetsValue];
}

- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets
{
	objc_setAssociatedObject( self, "_touchAreaInsets", [NSValue valueWithUIEdgeInsets:touchAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
	CGRect bounds = self.bounds;
	bounds = CGRectMake( bounds.origin.x - touchAreaInsets.left,
						bounds.origin.y - touchAreaInsets.top,
						bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
						bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom );
	return CGRectContainsPoint( bounds, point );
}

@end
