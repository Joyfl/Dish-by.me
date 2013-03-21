//
//  DMBookButton.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMBookButton.h"

@implementation DMBookButton

+ (id)bookButtonWithPosition:(CGPoint)position title:(NSString *)title
{
	DMBookButton *button = [[DMBookButton alloc] initWithFrame:CGRectMake( position.x, position.y, 260, 36 )];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithHex:0xF3EEE9 alpha:1] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"book_button.png"] forState:UIControlStateNormal];
	return button;
}

+ (id)blueBookButtonWithPosition:(CGPoint)position title:(NSString *)title
{
	DMBookButton *button = [[DMBookButton alloc] initWithFrame:CGRectMake( position.x, position.y, 260, 36 )];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithHex:0xF3EEE9 alpha:1] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"book_button_blue.png"] forState:UIControlStateNormal];
	return button;
}

@end
