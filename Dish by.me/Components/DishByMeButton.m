//
//  DishByMeButtonl.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 22..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishByMeButton.h"

@implementation DishByMeButton

- (id)initWithTitle:(NSString *)title
{
	self = [super init];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	self.titleLabel.shadowOffset = CGSizeMake( 0, -1 );
	[self setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.3] forState:UIControlStateNormal];
	[self setTitle:title forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
	
	return self;
}

@end
