//
//  JLSwitch.h
//  JLSwitch
//
//  Created by 전수열 on 13. 6. 7..
//  Copyright (c) 2013년 전수열. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLSwitch : UIControl
{
	UIImageView *_backgroundView;
	UIImageView *_blueBackgroundView;
	
	UIButton *_knob;
	UIImageView *_knobBlueBorder;
	
	UIImageView *_onIcon;
	UIImageView *_offIcon;
	
	CGFloat _touchDistance;
	BOOL _dragging;
}

@property (nonatomic, assign) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
