//
//  DishListCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 6..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DishListCell.h"
#import "JLHTTPLoader.h"
#import "Utils.h"
#import <QuartzCore/CALayer.h>
#import "UserManager.h"

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


@implementation DishListCell

@synthesize delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_photoView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 12, 292, 292 )];
	_photoView.image = [UIImage imageNamed:@"placeholder.png"];
	_photoView.userInteractionEnabled = YES;
	[_photoView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewDidTap)] autorelease]];
	[self.contentView addSubview:_photoView];
	
	UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, 350 )];
	frameView.image = [UIImage imageNamed:@"dish_border_big.png"];
	[self.contentView addSubview:frameView];
	
	_commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 22, 280, 13, 17 )];
	_commentIconView.image = [UIImage imageNamed:@"icon_comment.png"];
	[self.contentView addSubview:_commentIconView];
	
	_commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 38, 281, 18, 13 )];
	_commentCountLabel.textColor = [UIColor whiteColor];
	_commentCountLabel.backgroundColor = [UIColor clearColor];
	_commentCountLabel.font = [UIFont boldSystemFontOfSize:13];
	_commentCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_commentCountLabel.shadowOffset = CGSizeMake( 0, 1 );
	_commentCountLabel.textAlignment = NSTextAlignmentCenter;
	[self.contentView addSubview:_commentCountLabel];
	
	_bookmarkIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 59, 280, 13, 17 )];
	[self.contentView addSubview:_bookmarkIconView];
	
	_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 74, 281, 18, 13 )];
	_bookmarkCountLabel.textColor = [UIColor whiteColor];
	_bookmarkCountLabel.backgroundColor = [UIColor clearColor];
	_bookmarkCountLabel.font = [UIFont boldSystemFontOfSize:13];
	_bookmarkCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_bookmarkCountLabel.shadowOffset = CGSizeMake( 0, 1 );
	_bookmarkCountLabel.textAlignment = NSTextAlignmentCenter;
	[self.contentView addSubview:_bookmarkCountLabel];
	
	_dishNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 16, 312, 280, 20 )];
	_dishNameLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
	_dishNameLabel.font = [UIFont boldSystemFontOfSize:16];
	_dishNameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_dishNameLabel.shadowOffset = CGSizeMake( 0, 1 );
	[self.contentView addSubview:_dishNameLabel];
	
	_userNameLabel = [[UILabel alloc] init];
	_userNameLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
	_userNameLabel.font = [UIFont systemFontOfSize:11];
	_userNameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_userNameLabel.shadowOffset = CGSizeMake( 0, 1 );
	[self.contentView addSubview:_userNameLabel];
	
	_bookmarkLabel = [[UILabel alloc] init];
	_bookmarkLabel.text = NSLocalizedString( @"BOOKMARK", @"북마크" );
	_bookmarkLabel.textColor = [UIColor colorWithWhite:0 alpha:0.3];
	_bookmarkLabel.font = [UIFont boldSystemFontOfSize:12];
	[_bookmarkLabel sizeToFit];
	_bookmarkLabel.frame = CGRectMake( 282 - _bookmarkLabel.frame.size.width, 316, _bookmarkLabel.frame.size.width, 15 );
	[self.contentView addSubview:_bookmarkLabel];
	
	_bookmarkButtonContainer = [[UIView alloc] initWithFrame:CGRectMake( 210, 290, 100, 60 )];
	[self.contentView addSubview:_bookmarkButtonContainer];
	
	_bookmarkButton = [[LargeTouchAreaButton alloc] init];
	[_bookmarkButton setImage:[UIImage imageNamed:@"ribbon.png"] forState:UIControlStateNormal];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonDrag:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_bookmarkButton addTarget:self action:@selector(bookmarkButtonTouchUp) forControlEvents:UIControlEventTouchUpOutside];
	[_bookmarkButtonContainer addSubview:_bookmarkButton];
	
	CALayer *maskLayer = [CALayer layer];
	maskLayer.contents = (id)[UIImage imageNamed:@"search_bar.png"].CGImage;
	maskLayer.bounds = CGRectMake( 0, 0, 200, 400 );
	_bookmarkButtonContainer.layer.mask = maskLayer;
	
	UIImageView *ribbonGradientView = [[UIImageView alloc] initWithFrame:CGRectMake( 96, 22, 4, 20 )];
	ribbonGradientView.image = [UIImage imageNamed:@"ribbon_gradient.png"];
	[_bookmarkButtonContainer addSubview:ribbonGradientView];
	
	return self;
}


#pragma mark -
#pragma mark Getter/Setter

- (Dish *)dish
{
	return _dish;
}

- (void)setDish:(Dish *)dish atIndexPath:(NSIndexPath *)indexPath
{
	_dish = [dish retain];
	_indexPath = [indexPath retain];
	[self fillContents];
	[self layoutContentView];
}


- (void)fillContents
{
	_photoView.image = [UIImage imageNamed:@"placeholder.png"];
	if( _dish.photo )
	{
		_photoView.image = _dish.photo;
	}
	else
	{
		[JLHTTPLoader loadAsyncFromURL:_dish.photoURL withObject:_indexPath completion:^(id indexPath, NSData *data)
		{
			_dish.photo = [UIImage imageWithData:data];
			
			if( [_indexPath isEqual:indexPath] )
				_photoView.image = _dish.photo;
		}];
	}
	
	_commentCountLabel.text = [NSString stringWithFormat:@"%d", _dish.commentCount];
	_dishNameLabel.text = _dish.dishName;
	_userNameLabel.text = [NSString stringWithFormat:@"by %@", _dish.userName];
	
	[self updateBookmarkUI];
	
	_bookmarkButtonContainer.hidden = ![UserManager manager].loggedIn;
		 
	if( _dish.bookmarked )
		[self setBookmarkButtonX:10];
	else
		[self setBookmarkButtonX:75];
}

- (void)updateBookmarkUI
{
	_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _dish.bookmarkCount];
	
	if( !_dish.bookmarked )
	{
		_bookmarkIconView.image = [UIImage imageNamed:@"icon_bookmark.png"];
		_bookmarkCountLabel.textColor = [UIColor whiteColor];
	}
	else
	{
		_bookmarkIconView.image = [UIImage imageNamed:@"icon_bookmark_selected.png"];
		_bookmarkCountLabel.textColor = [Utils colorWithHex:0x0DCFEC alpha:1];
	}
}

- (void)layoutContentView
{
	[_dishNameLabel sizeToFit];
	
	_userNameLabel.frame = CGRectMake( _dishNameLabel.frame.origin.x + _dishNameLabel.frame.size.width + 10, 317, 100, 15 );
	[_userNameLabel sizeToFit];
}


#pragma mark -
#pragma mark Photo View

- (void)photoViewDidTap
{
	NSLog( @"tap" );
	[delegate dishListCell:self didTouchPhotoViewAtIndexPath:_indexPath];
}


#pragma mark -
#pragma mark Bookmark Button

- (void)bookmarkButtonDrag:(UIButton *)button withEvent:(UIEvent *)event
{
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
			[self setBookmarked:YES animated:NO];
		else
			[self setBookmarked:NO animated:NO];
	}
}

- (void)bookmarkButtonTouchUpInside
{
	// Just touch when not bookmarked
	if( _bookmarkButton.frame.origin.x == 75 )
	{
		[UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[self setBookmarkButtonX:65];
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				[self setBookmarkButtonX:75];
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					[self setBookmarkButtonX:70];
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
						[self setBookmarkButtonX:75];
					} completion:nil];
				}];
			}];
		}];
	}
	
	// Just touch when bookmarked
	else if( _bookmarkButton.frame.origin.x == 10 )
	{
		[self setBookmarked:NO animated:YES];
	}
	else
	{
		[self bookmarkButtonTouchUp];
	}
}

- (void)bookmarkButtonTouchUp
{
	// Swipe to bookmark
	if( _bookmarkButton.frame.origin.x < 30 )
	{
		[self setBookmarked:YES animated:YES];
	}
	
	// Swipe to unbookmark
	else if( _bookmarkButton.frame.origin.x >= 30 )
	{
		[self setBookmarked:NO animated:YES];
	}
}

- (void)setBookmarked:(BOOL)bookmarked animated:(BOOL)animated
{
	if( bookmarked )
	{
		if( !_dish.bookmarked )
		{
			[delegate dishListCell:self didBookmarkAtIndexPath:_indexPath];
			
			_dish.bookmarked = YES;
			_dish.bookmarkCount++;
			[self updateBookmarkUI];
			
			[UIView animateWithDuration:0.18 animations:^{
				_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.14 animations:^{
					_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.12 animations:^{
						_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
					} completion:^(BOOL finished) {
						[UIView animateWithDuration:0.1 animations:^{
							_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
						}];
					}];
				}];
			}];
			
			[UIView animateWithDuration:0.2 delay:0.14 options:0 animations:^{
				_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.15 animations:^{
					_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.12 animations:^{
						_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
					} completion:^(BOOL finished) {
						[UIView animateWithDuration:0.1 animations:^{
							_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
						}];
					}];
				}];
			}];
		}
		
		if( animated )
		{
			[UIView animateWithDuration:0.25 animations:^{
				_bookmarkLabel.alpha = 0;
				[self setBookmarkButtonX:10];
			}];
		}
	}
	else if( !bookmarked )
	{
		if( _dish.bookmarked )
		{
			[delegate dishListCell:self didUnbookmarkAtIndexPath:_indexPath];
			
			_dish.bookmarked = NO;
			_dish.bookmarkCount--;
			[self updateBookmarkUI];
		}
		
		if( animated )
		{
			[UIView animateWithDuration:0.25 animations:^{
				_bookmarkLabel.alpha = 1;
				[self setBookmarkButtonX:75];
			}];
		}
	}
}

- (void)setBookmarkButtonX:(CGFloat)x
{
	_bookmarkButton.frame = CGRectMake( x, 21, 100, 25 );
}

@end
