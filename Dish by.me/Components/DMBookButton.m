//
//  DMBookButton.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMBookButton.h"

@implementation DMBookButton

- (id)initWithPosition:(CGPoint)position title:(NSString *)title
{
    self = [super initWithFrame:CGRectMake( position.x, position.y, 260, 36 )];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	self.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[self setTitle:title forState:UIControlStateNormal];
	[self setTitleColor:[UIColor colorWithHex:0xF3EEE9 alpha:1] forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"book_button.png"] forState:UIControlStateNormal];
	return self;
}

@end
