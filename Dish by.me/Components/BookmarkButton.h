//
//  BookmarkButton.h
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"

@protocol BookmarkButtonDelegate;

@interface BookmarkButton : NSObject
{
	id<BookmarkButtonDelegate> delegate;
	UIView *_parentView;
	
	FXLabel *_bookmarkLabel;
	UIButton *_bookmarkButton;
	UIView *_bookmarkButtonContainer;
}

@property (nonatomic, retain) id<BookmarkButtonDelegate> delegate;
@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat buttonX;
@property (nonatomic, assign) BOOL hidden;

@end


@protocol BookmarkButtonDelegate

- (void)bookmarkButton:(BookmarkButton *)button didChangeBookmarked:(BOOL)bookmarked;

@end