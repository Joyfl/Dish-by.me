//
//  JLLabelButton.h
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 27..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLLabelButton : UIButton
{
	UIView *_highlightView;
}

@property (nonatomic, assign) UIEdgeInsets hightlightViewInsets;

@end
