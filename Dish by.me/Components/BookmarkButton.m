//
//  BookmarkButton.m
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "BookmarkButton.h"
#import <QuartzCore/CALayer.h>

@interface LargeTouchAreaButton : UIButton
@end

@implementation LargeTouchAreaButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	CGRect bounds = self.bounds;
	bounds = CGRectMake( bounds.origin.x - 20,
						bounds.origin.y - 50,
						bounds.size.width + 40,
						bounds.size.height + 100 );
	return CGRectContainsPoint( bounds, point );
}

@end


@implementation BookmarkButton

@synthesize delegate;

- (id)init
{
    self = [super init];
	
	_bookmarkLabel = [[UILabel alloc] init];
	_bookmarkLabel.text = NSLocalizedString( @"BOOKMARK", @"북마크" );
	_bookmarkLabel.textColor = [UIColor colorWithHex:0xB3B3B3 alpha:1];
	_bookmarkLabel.font = [UIFont boldSystemFontOfSize:12];
	_bookmarkLabel.backgroundColor = [UIColor clearColor];
//	_bookmarkLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.3];
//	_bookmarkLabel.shadowBlur = 1.5;
//	_bookmarkLabel.shadowOffset = CGSizeMake( 0, 1 );
//	_bookmarkLabel.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
//	_bookmarkLabel.layer.shadowOpacity = 0.08;
//	_bookmarkLabel.layer.shadowRadius = 1;
//	_bookmarkLabel.layer.shadowOffset = CGSizeMake( 0, -1 );
//	_bookmarkLabel.innerShadowColor = [UIColor colorWithWhite:0 alpha:0.2];
//	_bookmarkLabel.innerShadowBlur = 1;
//	_bookmarkLabel.innerShadowOffset = CGSizeMake( 0.5, 0.5 );
	[_bookmarkLabel sizeToFit];
	_bookmarkLabel.frame = CGRectMake( 72 - _bookmarkLabel.frame.size.width, 4, _bookmarkLabel.frame.size.width, 15 );
	
	_bookmarkButtonContainer = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 100, 60 )];
	
	_bookmarkButton = [[LargeTouchAreaButton alloc] initWithFrame:CGRectMake( 75, 0, 100, 25 )];
	[_bookmarkButton setImage:[UIImage imageNamed:@"ribbon.png"] forState:UIControlStateNormal];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonDrag:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
	[_bookmarkButtonContainer addSubview:_bookmarkButton];
	
	CALayer *maskLayer = [CALayer layer];
	maskLayer.contents = (id)[UIImage imageNamed:@"search_bar.png"].CGImage;
	maskLayer.bounds = CGRectMake( 0, -44, 200, 400 );
	_bookmarkButtonContainer.layer.mask = maskLayer;
	
	UIImageView *ribbonGradientView = [[UIImageView alloc] initWithFrame:CGRectMake( 96, 1, 4, 20 )];
	ribbonGradientView.image = [UIImage imageNamed:@"ribbon_gradient.png"];
	[_bookmarkButtonContainer addSubview:ribbonGradientView];
	
    return self;
}

- (void)bookmarkButtonDrag:(UIButton *)button withEvent:(UIEvent *)event
{
	_dragging = YES;
	
	UITouch *touch = [[event touchesForView:button] anyObject];
	CGPoint prevLocation = [touch previousLocationInView:_bookmarkButtonContainer];
	CGPoint location = [touch locationInView:_bookmarkButtonContainer];
	
	CGFloat deltaX = location.x - prevLocation.x;
	
	CGRect frame = button.frame;
	CGFloat buttonX = frame.origin.x + deltaX;
	
	if( 0 < buttonX && buttonX < 85 )
	{
		frame.origin = CGPointMake( buttonX, frame.origin.y );
		button.frame = frame;
		
		_bookmarkLabel.alpha = ( buttonX - 30 ) / 45;
		
		if( button.frame.origin.x < 30 )
			[delegate bookmarkButton:self didChangeBookmarked:YES];
		else
			[delegate bookmarkButton:self didChangeBookmarked:NO];
	}
}

- (void)bookmarkButtonTouchUpInside
{
	_dragging = NO;
	
	// Just touch when not bookmarked
	if( _bookmarkButton.frame.origin.x == 75 )
	{
		[UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.buttonX = 65;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				self.buttonX = 75;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					self.buttonX = 70;
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
						self.buttonX = 75;
					} completion:nil];
				}];
			}];
		}];
	}
	
	// Just touch when bookmarked
	else if( _bookmarkButton.frame.origin.x == 10 )
	{
		[delegate bookmarkButton:self didChangeBookmarked:NO];
		[self beginUnbookmarkAnimation];
	}
	else
	{
		[self bookmarkButtonTouchUpOutside];
	}
}

- (void)bookmarkButtonTouchUpOutside
{
	_dragging = NO;
	
	// Swipe to bookmark
	if( _bookmarkButton.frame.origin.x < 30 )
	{
		[delegate bookmarkButton:self didChangeBookmarked:YES];
		[self beginBookmarkAnimation];
	}
	
	// Swipe to unbookmark
	else if( _bookmarkButton.frame.origin.x >= 30 )
	{
		[delegate bookmarkButton:self didChangeBookmarked:NO];
		[self beginUnbookmarkAnimation];
	}
}

- (void)beginBookmarkAnimation
{
	[UIView animateWithDuration:0.25 animations:^{
		_bookmarkLabel.alpha = 0;
		self.buttonX = 10;
	}];
}

- (void)beginUnbookmarkAnimation
{
	[UIView animateWithDuration:0.25 animations:^{
		_bookmarkLabel.alpha = 1;
		self.buttonX = 75;
	}];
}


#pragma mark -
#pragma mark Getter/Setter

- (UIView *)parentView
{
	return _parentView;
}

- (void)setParentView:(UIView *)parentView
{
	_parentView = parentView;
	
	[_bookmarkLabel removeFromSuperview];
	[_bookmarkButtonContainer removeFromSuperview];
	
	[_parentView addSubview:_bookmarkLabel];
	[_parentView addSubview:_bookmarkButtonContainer];
}


// Right-Top position.
- (CGPoint)position
{
	return CGPointMake( _bookmarkButtonContainer.frame.origin.x + 100, _bookmarkButtonContainer.frame.origin.y );
}

- (void)setPosition:(CGPoint)position
{
	CGRect frame = _bookmarkLabel.frame;
	frame.origin = CGPointMake( position.x - 28 - _bookmarkLabel.frame.size.width, position.y + 4 );
	_bookmarkLabel.frame = frame;
	
	frame = _bookmarkButtonContainer.frame;
	frame.origin = CGPointMake( position.x - 100, position.y );
	_bookmarkButtonContainer.frame = frame;
}


- (CGFloat)buttonX
{
	return _bookmarkButton.frame.origin.x;
}

- (void)setButtonX:(CGFloat)buttonX
{
	_bookmarkButton.frame = CGRectMake( buttonX, 0, 100, 25 );
}


- (BOOL)hidden
{
	return _bookmarkLabel.hidden && _bookmarkButtonContainer.hidden;
}

- (void)setHidden:(BOOL)hidden
{
	_bookmarkLabel.hidden = _bookmarkButtonContainer.hidden = hidden;
}

@end
