//
//  BookmarkButton.h
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkButtonDelegate;

@interface BookmarkButton : NSObject
{
	id<BookmarkButtonDelegate> delegate;
	UIView *_parentView;
	
	UILabel *_bookmarkLabel;
	UIButton *_bookmarkButton;
	UIView *_bookmarkButtonContainer;
	
	BOOL _fakeBookmarked;
}

@property (nonatomic, retain) id<BookmarkButtonDelegate> delegate;
@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat buttonX;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL bookmarked;

@end


@protocol BookmarkButtonDelegate

- (void)bookmarkButton:(BookmarkButton *)button needsUpdateBookmarkUIAsBookmarked:(BOOL)bookmarked;
- (void)bookmarkButton:(BookmarkButton *)button didChangeBookmarked:(BOOL)bookmarked;

@end